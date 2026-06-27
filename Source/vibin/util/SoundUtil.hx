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

    /**
     * Plays a sound effect from the assets/sounds/ folder.
     * @param soundName The name of the sound file (without .ogg extension).
     * @param volume Optional volume scale from 0.0 to 1.0 (Defaults to 1.0).
     */
    public static function PlaySound(soundName:String, volume:Float = 1.0):Void
    {
        var path = 'assets/sounds/$soundName.ogg';
        FlxG.sound.play(path, volume);
    }

    public static function PlayMusic(
        musicName:String,
        fadeIn:Bool = false,
        persistent:Bool = false
    ):Void
    {
        // FIX: If this exact song is already playing, do absolutely nothing and let it continue vibin'
        if (FlxG.sound.music != null && FlxG.sound.music.playing && currentMusicName == musicName)
        {
            FlxG.sound.music.persist = persistent;
            return;
        }

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

    /**
     * Stops a specific music track by name, with an optional fade-out effect.
     * @param musicName The name of the song that should stop.
     * @param fadeOut If true, the music will gracefully fade out over 1 second before stopping.
     */
    public static function StopMusic(musicName:String, fadeOut:Bool = false):Void
    {
        // Only run if there is active music playing and it matches the requested song name
        if (FlxG.sound.music != null && currentMusicName == musicName)
        {
            if (fadeOut)
            {
                // Fade out over 1 second, from current volume down to 0
                FlxG.sound.music.fadeOut(1, 0, function(tween) {
                    FlxG.sound.music.stop();
                    currentMusicName = "";
                });
            }
            else
            {
                // Stop instantly
                FlxG.sound.music.stop();
                currentMusicName = "";
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