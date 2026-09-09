package util; // im so proud

import flixel.sound.FlxSound;

class SoundUtil {
    public static function playMusic(key:String, volume:Float = 1.0, looped:Bool = false, autoDestroy:Bool = true):FlxSound {
        return FlxG.sound.play("assets/music/" + key + "/music.ogg", volume, looped, null, autoDestroy);
    }
}