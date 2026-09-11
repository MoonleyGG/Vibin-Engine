package util; // im so proud

import flixel.sound.FlxSound;

class SoundUtil {
    public static function playMusic(key:String, volume:Float = 1.0, looped:Bool = false, autoDestroy:Bool = true, persist:Bool = false):FlxSound {
        var path:String = "assets/music/" + key + "/music.ogg";

        for (sound in FlxG.sound.list.members) {
            if (sound != null && sound.playing && sound.name == key) {
                return sound;
            }
        }

        var sound:FlxSound = FlxG.sound.play(path, volume, looped, null, autoDestroy);

        if (sound != null) {
            sound.presist = persist;
            sound.name = key; // tag it so its findable in the loop next time
        }

        return sound;
    }
}