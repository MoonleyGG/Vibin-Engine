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
    public static var keyCount:Int = 1;
    // 1. Add the scrollSpeed static variable with a default of 2.0
    public static var scrollSpeed:Float = 2.0; 

    public static function loadSongMetadata(song:String, currentBpm:Int):Void
    {
        var metadataPath = 'assets/songs/$song/metadata.xml';

        if (Assets.exists(metadataPath))
        {
            var fileContent:String = Assets.getText(metadataPath);
            var loadedPlayer:String = extractXmlTagValue(fileContent, "player", player);
            var loadedOpponent:String = extractXmlTagValue(fileContent, "opponent", opponent);
            var loadedBpmText:String = extractXmlTagValue(fileContent, "bpm", Std.string(currentBpm));
            var parsedBpm:Null<Int> = Std.parseInt(loadedBpmText);
            var loadedKeyCountText:String = extractXmlTagValue(fileContent, "keyCount", Std.string(keyCount));
            var parsedKeyCount:Null<Int> = Std.parseInt(loadedKeyCountText);

            // 2. Extract and parse the scroll speed from metadata.xml
            var loadedScrollSpeedText:String = extractXmlTagValue(fileContent, "scrollSpeed", Std.string(scrollSpeed));
            var parsedScrollSpeed:Null<Float> = Std.parseFloat(loadedScrollSpeedText);

            player = loadedPlayer.length > 0 ? loadedPlayer : player;
            opponent = loadedOpponent.length > 0 ? loadedOpponent : opponent;
            if (parsedBpm != null && parsedBpm > 0)
                bpm = parsedBpm;
            if (parsedKeyCount != null && parsedKeyCount > 0)
                keyCount = parsedKeyCount;
            
            // 3. Assign the parsed speed if valid
            if (parsedScrollSpeed != null && parsedScrollSpeed > 0)
                scrollSpeed = parsedScrollSpeed;

            songMetadataAvailable = true;
        }
        else
        {
            songMetadataAvailable = false;
            // Fallback default value if no metadata exists
            scrollSpeed = 2.0; 
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

        return content.substring(start + openTag.length, end);
    }
}