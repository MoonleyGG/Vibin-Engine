package vibin.objects.playstate;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import lime.utils.Assets;

class StrumNote extends FlxSprite
{
    public var direction:String;
    public var noteOffsets:Dynamic;

    public function new(X:Float, Y:Float, imagePath:String, xmlPath:String, direction:String)
    {
        super(X, Y);

        this.direction = direction;

        loadNoteOffsets();

        frames = FlxAtlasFrames.fromSparrow(imagePath, xmlPath);

        animation.addByPrefix("static", direction + " static", 24, false);
        animation.addByPrefix("miss", direction + " miss", 24, false);
        animation.addByPrefix("hit", direction + " hit", 24, false);
        // same frames as "hit" but looped - used while a sustain note is being held
        animation.addByPrefix("holdHit", direction + " hit", 24, true);

        animation.play("static");
        applyOffset("static");

        // "hit" and "miss" are one-shot (looped = false), so once the last
        // frame plays, Flixel just freezes there. Kick it back to "static"
        // whenever a non-looping animation finishes. "holdHit" is looped
        // on purpose, so it's excluded here - that one gets stopped
        // explicitly by InputSystem when the hold ends (see StopHoldAnimation).
        animation.finishCallback = function(name:String):Void
        {
            if (name == "hit" || name == "miss")
                PlayAnimation("static");
        };

        antialiasing = true;

        scale.set(0.75, 0.75);
    }

    public function PlayAnimation(anim:String):Void
    {
        animation.play(anim);
        applyOffset(anim);
    }

    /**
     * Starts the looping "held" pose for a sustain note. Keeps playing
     * until StopHoldAnimation() is called - it will NOT auto-revert to
     * static on its own, since a looped animation never "finishes".
     */
    public function PlayHoldAnimation():Void
    {
        animation.play("holdHit");
        applyOffset("hit"); // reuse the "hit" offset tuning, same frames
    }

    /**
     * Ends a held sustain pose. success = true plays a clean return to
     * static; success = false plays "miss" (which then auto-reverts to
     * static once it finishes, via finishCallback above).
     */
    public function StopHoldAnimation(success:Bool):Void
    {
        PlayAnimation(success ? "static" : "miss");
    }

    function applyOffset(anim:String):Void
    {
        if (noteOffsets == null)
            return;

        var mode = Reflect.field(noteOffsets, anim);
        if (mode == null)
            return;

        var off = Reflect.field(mode, direction);
        if (off == null)
            return;

        offset.set(off.x, off.y);
    }

    function loadNoteOffsets():Void
    {
        // sane zeroed defaults in case there's no NoteOffsets.json yet
        noteOffsets =
        {
            "static":
            {
                left: {x: 0, y: 0},
                down: {x: 0, y: 0},
                up: {x: 0, y: 0},
                right: {x: 0, y: 0}
            },

            "miss":
            {
                left: {x: 0, y: 0},
                down: {x: 0, y: 0},
                up: {x: 0, y: 0},
                right: {x: 0, y: 0}
            },

            "hit":
            {
                left: {x: 0, y: 0},
                down: {x: 0, y: 0},
                up: {x: 0, y: 0},
                right: {x: 0, y: 0}
            }
        };

        var path = "assets/data/notes/NoteOffsets.json";

        if (Assets.exists(path))
        {
            try
            {
                noteOffsets = Json.parse(Assets.getText(path));
            }
            catch (e:Dynamic)
            {
                trace('StrumNote: failed to parse NoteOffsets.json: $e');
            }
        }
    }
}
