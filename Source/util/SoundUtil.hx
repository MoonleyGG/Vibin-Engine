package util;

import flixel.sound.FlxSound;

class SoundUtil
{
    public static var activeTracks:Map<String, FlxSound> = [];

    public static function playMusic(key:String, volume:Float = 1, looped:Bool = true, persist:Bool = true):FlxSound
    {
        var sound = activeTracks.get(key);

        if (sound != null)
        {
            sound.volume = volume;

            if (!sound.playing)
                sound.play();

            return sound;
        }

        sound = new FlxSound();
        sound.load("assets/music/" + key + "/music.ogg");
        sound.volume = volume;
        sound.looped = looped;
        sound.persist = persist;
        sound.autoDestroy = false;

        FlxG.sound.list.add(sound);
        activeTracks.set(key, sound);

        sound.onComplete = function()
        {
            if (!looped)
                activeTracks.remove(key);
        };

        sound.play();

        return sound;
    }

    public static function stopMusic(key:String):Void
    {
        var sound = activeTracks.get(key);

        if (sound == null)
            return;

        sound.stop();
        sound.destroy();
        activeTracks.remove(key);
    }

    public static function stopAllMusic():Void
    {
        for (sound in activeTracks)
        {
            sound.stop();
            sound.destroy();
        }

        activeTracks.clear();
    }

    public static function getMusic(key:String):FlxSound
    {
        return activeTracks.get(key);
    }

    public static function isPlaying(key:String):Bool
    {
        var sound = activeTracks.get(key);
        return sound != null && sound.playing;
    }
}
