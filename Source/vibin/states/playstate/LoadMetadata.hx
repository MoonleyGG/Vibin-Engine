package vibin.states.playstate;

import lime.utils.Assets;
import flixel.FlxG;
import StringTools;

class LoadMetadata
{
    public static var songMetadataAvailable:Bool = false;
    public static var player:String = "Boyfriend";
    public static var opponent:String = "Dad";
    public static var bpm:Int = 100;

    public static function loadSongMetadata(song:String, currentBpm:Int):Void
    {
        var metadataPath = 'assets/data/$song/metadata.xml';

        if (Assets.exists(metadataPath))
        {
            var fileContent:String = Assets.getText(metadataPath);
            var loadedPlayer:String = extractXmlTagValue(fileContent, "player", player);
            var loadedOpponent:String = extractXmlTagValue(fileContent, "opponent", opponent);
            var loadedBpmText:String = extractXmlTagValue(fileContent, "bpm", Std.string(currentBpm));
            var parsedBpm:Null<Int> = Std.parseInt(loadedBpmText);

            player = loadedPlayer.length > 0 ? loadedPlayer : player;
            opponent = loadedOpponent.length > 0 ? loadedOpponent : opponent;
            if (parsedBpm != null && parsedBpm > 0) bpm = parsedBpm;

            songMetadataAvailable = true;
            trace('Loaded metadata for $song: player=$player opponent=$opponent bpm=$bpm');
        }
        else
        {
            songMetadataAvailable = false;
            trace('Missing metadata XML: ' + metadataPath + ' — continuing without song playback.');
        }
    }

    private static function extractXmlTagValue(content:String, tag:String, fallback:String):String
    {
        var openTag = '<' + tag + '>';
        var closeTag = '</' + tag + '>';
        var start = content.indexOf(openTag);
        if (start < 0) return fallback;

        var end = content.indexOf(closeTag, start + openTag.length);
        if (end < 0) return fallback;

        return StringTools.trim(content.substring(start + openTag.length, end));
    }
}