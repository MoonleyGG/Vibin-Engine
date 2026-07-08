package vibin.util;

import flixel.FlxG;
import flixel.sound.FlxSound;
import lime.utils.Assets;

using StringTools;

class SoundUtil
{
    public static var currentMusic:FlxSound;

    public static var currentMusicName:String = "";

    public static var currentSongLayerSounds:Array<FlxSound> = [];

    public static var GetInfo:MusicInfoResolver = new MusicInfoResolver(new MusicInfoImpl());

    public static function PlaySound(soundName:String, volume:Float = 1.0):Void
    {
        var path = 'assets/sounds/$soundName.ogg';
        FlxG.sound.play(path, volume);
    }

    public static function PlaySong(songPath:String, fadeIn:Bool = false, volume:Float = 1.0, startTime:Float = 0.0, endTime:Float = -1.0, loop:Bool = true):Void
    {
        // stop existing stems
        if (currentSongLayerSounds.length > 0)
        {
            for (soundItem in currentSongLayerSounds)
            {
                if (soundItem != null)
                {
                    soundItem.stop();
                    soundItem.destroy();
                }
            }
            currentSongLayerSounds = [];
        }
        if (FlxG.sound.music != null) FlxG.sound.music.stop();

        var baseDirectory = 'assets/songs/$songPath';
        var trackedFiles:Array<String> = [];

        if (Assets.exists(baseDirectory + '.ogg'))
        {
            trackedFiles.push(baseDirectory + '.ogg');
            currentMusicName = songPath;
        }
        else
        {
            var allAssets = Assets.list();
            for (asset in allAssets)
            {
                if (asset.startsWith(baseDirectory + '/') && asset.endsWith('.ogg'))
                {
                    trackedFiles.push(asset);
                }
            }
            currentMusicName = songPath;
        }

        if (trackedFiles.length == 0) return;

        // Load all stems first, wait for all to finish loading, then start them together
        var pendingSounds:Array<FlxSound> = [];
        var loadedCount:Int = 0;
        var totalStems:Int = trackedFiles.length;

        var resolveEmbeddedAsset = function(path:String):Null<String>
        {
            if (Assets.exists(path))
                return path;

            var assetsPrefix = "assets/";
            if (path.startsWith(assetsPrefix))
            {
                var stripped = path.substr(assetsPrefix.length);
                if (Assets.exists(stripped))
                    return stripped;
            }
            else
            {
                var prefixed = assetsPrefix + path;
                if (Assets.exists(prefixed))
                    return prefixed;
            }

            return null;
        };

        var onAllLoaded = function() {
            var startTimeMs = startTime * 1000;

            for (s in pendingSounds)
            {
                if (s != null)
                {
                    s.play(true, startTimeMs);
                }
            }

            if (fadeIn)
            {
                for (s in pendingSounds)
                {
                    if (s != null)
                    {
                        s.volume = 0;
                        s.fadeIn(1, 0, volume);
                    }
                }
            }
            else
            {
                for (s in pendingSounds)
                    if (s != null) s.volume = volume;
            }
        }

        for (i in 0...trackedFiles.length)
        {
            var audioTrackPath = trackedFiles[i];
            var stemSound:FlxSound;
            var embeddedId:Null<String> = resolveEmbeddedAsset(audioTrackPath);

            if (embeddedId != null)
            {
                stemSound = FlxG.sound.load(embeddedId, volume, loop, null, false, false);
                if (stemSound != null)
                {
                    pendingSounds.push(stemSound);
                    currentSongLayerSounds.push(stemSound);

                    if (i == 0)
                        currentMusic = stemSound;

                    loadedCount++;
                    continue;
                }
            }

            stemSound = FlxG.sound.load(null, volume, loop, null, false, false, audioTrackPath,
                null,
                function()
                {
                    loadedCount++;
                    if (loadedCount >= totalStems)
                        onAllLoaded();
                }
            );

            if (stemSound != null)
            {
                pendingSounds.push(stemSound);
                currentSongLayerSounds.push(stemSound);

                if (i == 0)
                    currentMusic = stemSound;
            }
        }

        if (loadedCount >= totalStems)
            onAllLoaded();

        if (loadedCount >= totalStems)
            onAllLoaded();
        // end PlaySong
    }

    public static function StopSong(fadeOut:Bool = false):Void
    {
        currentMusicName = "";

        if (currentSongLayerSounds.length == 0) return;

        var soundsToClear = currentSongLayerSounds.copy();
        currentSongLayerSounds = [];

        for (soundItem in soundsToClear)
        {
            if (soundItem != null && soundItem.playing)
            {
                if (fadeOut)
                {
                    soundItem.fadeOut(1, 0, function(tween) {
                        soundItem.stop();
                        soundItem.destroy();
                    });
                }
                else
                {
                    soundItem.stop();
                    soundItem.destroy();
                }
            }
        }
    }

    public static function PlayMusic(
        musicName:String,
        fadeIn:Bool = false,
        persistent:Bool = false
    ):Void
    {
        if (FlxG.sound.music != null && FlxG.sound.music.playing && currentMusicName == musicName)
        {
            FlxG.sound.music.persist = persistent;
            return;
        }

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

    public static function StopMusic(musicName:String, fadeOut:Bool = false):Void
    {
        if (FlxG.sound.music != null && currentMusicName == musicName)
        {
            if (fadeOut)
            {
                FlxG.sound.music.fadeOut(1, 0, function(tween) {
                    FlxG.sound.music.stop();
                    currentMusicName = "";
                });
            }
            else
            {
                FlxG.sound.music.stop();
                currentMusicName = "";
            }
        }
    }
}

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

class MusicInfoImpl
{
    public function new() {}

    public function getBpm(field:String):Int
    {
        var iniPath = 'assets/songs/$field.ini';
        if (!Assets.exists(iniPath)) iniPath = 'assets/music/$field.ini';
        
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

        return 100; 
    }
}