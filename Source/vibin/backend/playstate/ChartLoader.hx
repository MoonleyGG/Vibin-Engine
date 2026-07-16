package vibin.backend.playstate;

import lime.utils.Assets;
import haxe.Json;

import vibin.objects.playstate.Note;

/**
 * Matches the chart.json note format:
 * {
 *   "N": 3,     // flat note index (0 - infinite): strumlineIndex = N div keyCount, columnIndex = N mod keyCount
 *   "T": 600,   // ms this note should be hit
 *   "NT": 2,    // 1 = tap note, 2 = hold note
 *   "SE": 1200  // ms the hold ends at (absolute, not a duration). Omitted/absent = tap note.
 * }
 */
typedef ChartNoteData =
{
    N:Int,
    T:Float,
    ?NT:Int,
    ?SE:Float
}

class ChartLoader
{
    public static var chartAvailable:Bool = false;

    /**
     * Reads and parses assets/songs/<song>/chart.json into raw note data.
     * Returns an empty array (and sets chartAvailable = false) if the file
     * is missing or fails to parse, rather than throwing.
     */
    public static function loadChartData(song:String):Array<ChartNoteData>
    {
        var path = 'assets/songs/$song/chart.json';

        if (!Assets.exists(path))
        {
            trace('ChartLoader: no chart.json found for "$song" at $path');
            chartAvailable = false;
            return [];
        }

        var rawData:Array<ChartNoteData>;

        try
        {
            rawData = Json.parse(Assets.getText(path));
        }
        catch (e:Dynamic)
        {
            trace('ChartLoader: failed to parse chart for "$song": $e');
            chartAvailable = false;
            return [];
        }

        if (rawData == null)
        {
            chartAvailable = false;
            return [];
        }

        chartAvailable = true;
        return rawData;
    }

    /**
     * Parses the chart and builds playable Note objects, resolving each
     * note's flat "N" index into a strumline + column + direction.
     * Notes that resolve to a strumline outside strumlineCount are skipped
     * (rather than crashing), so malformed/oversized charts fail safely.
     *
     * pathPrefix should point at the folder containing notes.png/xml and
     * NoteHoldAssets.png/xml (e.g. "assets/images/").
     * pixelsPerMs is the final scroll speed (base speed * scrollSpeed),
     * used once here to size hold-note sustain trails to the right length.
     */
    public static function createNotes(song:String, strumlineCount:Int, keyCount:Int, keyDirections:Array<String>, pathPrefix:String, pixelsPerMs:Float):Array<Note>
    {
        var rawData = loadChartData(song);
        var notes:Array<Note> = [];

        if (keyCount <= 0 || keyDirections.length == 0)
            return notes;

        for (data in rawData)
        {
            if (data == null || data.N < 0)
                continue;

            var strumlineIndex:Int = Std.int(data.N / keyCount);
            var columnIndex:Int = data.N % keyCount;

            if (strumlineIndex < 0 || strumlineIndex >= strumlineCount)
            {
                trace('ChartLoader: note N=${data.N} at T=${data.T} resolves to strumline $strumlineIndex, which doesn\'t exist — skipping');
                continue;
            }

            var direction:String = keyDirections[columnIndex % keyDirections.length].toLowerCase();

            var noteType:Int = (data.NT != null) ? data.NT : 1;
            var sustainEnd:Float = (data.SE != null) ? data.SE : -1;

            var note = new Note(
                data.N,
                data.T,
                noteType,
                sustainEnd,
                strumlineIndex,
                columnIndex,
                direction,
                pathPrefix + "notes.png",
                pathPrefix + "notes.xml",
                pathPrefix + "NoteHoldAssets.png",
                pathPrefix + "NoteHoldAssets.xml",
                pixelsPerMs
            );

            notes.push(note);
        }

        // earliest notes first, makes spawning/culling in PlayState straightforward
        notes.sort(function(a, b) return Std.int(a.strumTime - b.strumTime));

        return notes;
    }
}
