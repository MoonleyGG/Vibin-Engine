package vibin.backend;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import vibin.util.SoundUtil;

class MusicBeatState extends FlxTransitionableState
{
    public var BPM:Int = 100;
    
    // Tracks the current active beat number
    public var curBeat:Int = 0;
    
    private var lastBeatTime:Float = 0;
    private var beatStep:Float = 0;

    override public function create():Void
    {
        super.create();

        // Check if a song name was cached in our SoundUtil layout
        if (SoundUtil.currentMusicName != "")
        {
            // Set the state's BPM automatically from the matching INI file
            BPM = SoundUtil.GetInfo.resolve(SoundUtil.currentMusicName);
        }

        // Calculate how many seconds pass per single beat
        beatStep = 60 / BPM;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (SoundUtil.currentMusic != null && SoundUtil.currentMusic.playing)
        {
            // Sync tracking with the sound's current playing timestamp (converted to seconds)
            var musicTime:Float = SoundUtil.currentMusic.time / 1000;

            if (musicTime >= lastBeatTime + beatStep)
            {
                curBeat++;
                lastBeatTime += beatStep;
                beatHit();
            }
            else if (musicTime < lastBeatTime)
            {
                // Reset tracker if the song loops or restarts
                lastBeatTime = 0;
                curBeat = 0;
            }
        }
    }

    /**
     * Called automatically every time a beat occurs. 
     * Open for child states to extend via 'override'.
     */
    public function beatHit():Void
    {
        // Handled by child states
    }
}