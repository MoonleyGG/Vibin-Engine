package vibin.backend.backendStates;

import flixel.FlxState;
import flixel.util.FlxTimer;

class MusicUIBeatState extends FlxState {
    public var BPM:Float = 100;
    public var beat:Float = 1;
    public var step:Float = 1;

    override function create() {
        super.create();

        new FlxTimer().start(60 / BPM, function(timer:FlxTimer) {
            beat += 1;
            step = beat * 4;
        }, 0);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}