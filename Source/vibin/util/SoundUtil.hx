package vibin.util;

import flixel.FlxG;
import flixel.sound.FlxSound;
import lime.utils.Assets;

using StringTools;

class SoundUtil
{
    public static var currentMusic:FlxSound;
    
    // Tracks the exact filename string for MusicBeatState to read later
    public static var currentMusicName:String = "";

    // Direct access helper instance variable
    public static var GetInfo:MusicInfoResolver = new MusicInfoResolver(new MusicInfoImpl());

    public static function PlayMusic(
        musicName:String,
        fadeIn:Bool = false,
        persistent:Bool = false
    ):Void
    {
        // Remember the song name globally
        currentMusicName = musicName;

        var path = 'assets/music/$musicName.ogg';

        FlxG.sound.playMusic(path);

        currentMusic = FlxG.sound.music;

        if (currentMusic != null)
        {
            currentMusic.persist = persistent;

            if (fadeIn)
            {
                currentMusic.volume = 0;
                currentMusic.fadeIn(1, 0, 1);
            }
        }
    }
}

/**
 * The Haxe Abstract wrapper handling field resolution tricks.
 */
@:forward
abstract MusicInfoResolver(MusicInfoImpl) from MusicInfoImpl to MusicInfoImpl
{
    public inline function new(impl:MusicInfoImpl) {
        this = impl;
    }

    @:resolve
    public inline function resolve(name:String):Int {
        return this.getBpm(name);
    }
}

/**
 * The inner utility logic container that performs actual .ini file layout parsing.
 */
class MusicInfoImpl
{
    public function new() {}

    public function getBpm(field:String):Int
    {
        var iniPath = 'assets/music/$field.ini';
        
        if (Assets.exists(iniPath))
        {
            var fileContent:String = Assets.getText(iniPath);
            var lines = fileContent.split('\n');
            
            for (line in lines)
            {
                var cleanLine = line.trim();
                if (cleanLine.length == 0 || cleanLine.startsWith('[')) continue;

                if (cleanLine.contains('='))
                {
                    var parts = cleanLine.split('=');
                    var key = parts[0].trim().toLowerCase();
                    var value = parts[1].trim();
                    
                    if (key == "bpm")
                    {
                        var parsedBpm = Std.parseInt(value);
                        if (parsedBpm != null) {
                            return parsedBpm;
                        }
                    }
                }
            }
        }

        return 100; // Default fallback if .ini doesn't exist
    }
}