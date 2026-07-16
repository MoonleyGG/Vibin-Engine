package vibin.backend;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import vibin.util.SoundUtil;

class MusicBeatState extends FlxTransitionableState
{
    public var BPM:Int = 100;

    public var curBeat:Int = 0;
    public var songBeat:Int = -1;
    
    private var lastBeatTime:Float = 0;
    private var beatTimer:Float = 0;
    public var beatStep:Float = 0;
    private var countdownBeat:Int = 0;
    private var countdownDone:Bool = false;
    override public function create():Void
    {
        super.create();

        if (SoundUtil.currentMusicName != "")
        {
            BPM = SoundUtil.GetInfo.resolve(SoundUtil.currentMusicName);
        }

        beatStep = 60 / BPM;

        // Initialize beat timing for the countdown.
        lastBeatTime = 0;
        beatTimer = 0;
        countdownBeat = 0;
        countdownDone = false;
        if (SoundUtil.currentMusic != null && SoundUtil.currentMusic.playing)
        {
            lastBeatTime = SoundUtil.currentMusic.time / 1000;
        }

        postCreate();
    }

    public function postCreate():Void
    {
        // Override this in subclasses to run code after all create() initialization is done.
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (SoundUtil.currentMusic != null && SoundUtil.currentMusic.playing)
        {
            var musicTime:Float = SoundUtil.currentMusic.time / 1000;

            if (musicTime >= lastBeatTime + beatStep)
            {
                curBeat++;
                lastBeatTime += beatStep;

                if (countdownDone)
                {
                    songBeat++;
                    songBeatHit();
                }

                beatHit();
            }
            else if (musicTime < lastBeatTime)
            {
                lastBeatTime = 0;
                curBeat = 0;
            }
        }
        else if (!countdownDone)
        {
            beatTimer += elapsed;
            while (beatTimer >= beatStep)
            {
                beatTimer -= beatStep;
                curBeat++;
                beatHit();
            }
        }
    }

    public function beatHit():Void
    {
        // Jerster figured out how to do math and calculated why beat 3 is = beat 4
        if (!countdownDone)
        {
            if (countdownBeat == 3)
            {
                countdownDone = true;
                songBeat = 0;
                startSong();
                songBeatHit();
            }
            
            countdownBeat++;
        }
    }

    public function startSong():Void
    {
        // Override this in subclasses to start the song on beat 4
    }

    public function songBeatHit():Void
    {
        // Override this in subclasses for song-beat events starting at 0 when startSong() runs.
    }
}