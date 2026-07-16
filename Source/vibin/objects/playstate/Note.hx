package vibin.objects.playstate;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import haxe.Json;

class Note extends FlxSpriteGroup
{
    // scale used for the head, sustain loop (x-axis), and sustain end cap.
    // matches the strum receptor's own scale so nothing drifts off-center
    // due to a size mismatch between the two atlases.
    public static inline var NOTE_SCALE:Float = 0.75;

    // ==== raw chart data (straight from chart.json) ====
    public var rawColumn:Int;         // N  - the raw flat note index from the chart
    public var strumTime:Float;       // T  - ms when this note should be hit
    public var noteType:Int;          // NT - 1 = tap, 2 = hold
    public var sustainEnd:Float = -1; // SE - ms when the hold ends, -1 if not a hold note

    // ==== resolved position info ====
    public var strumlineIndex:Int;    // which strumline (opponent/player/etc) this belongs to
    public var columnIndex:Int;       // which key within that strumline (0..keyCount-1)
    public var direction:String;      // "left" / "down" / "up" / "right"

    // ==== derived / gameplay state ====
    public var isSustain:Bool = false;
    public var sustainLength:Float = 0; // SE - T, in ms (0 if not a hold note)

    public var wasHit:Bool = false;
    public var tooLate:Bool = false;
    public var canBeHit:Bool = false;

    public var head(default, null):FlxSprite;

    var sustainLoop:FlxSprite;
    var sustainEndCap:FlxSprite;

    // full (unconsumed) loop scale.y, computed once at construction from
    // the hold's total length - the "eating" animation shrinks toward 0
    // from this starting point.
    var fullLoopScaleY:Float = 0;

    // caches parsed atlases so we don't re-parse the same xml for every single note
    static var atlasCache:Map<String, FlxAtlasFrames> = new Map();

    // shared, loaded once - "note" offsets apply to the head, "sustainLoop"
    // offsets apply to the hold trail. Tuned in NoteOffsetEditorState.
    static var noteOffsets:Dynamic;
    static var offsetsLoaded:Bool = false;

    public function new(rawColumn:Int, strumTime:Float, noteType:Int, sustainEnd:Float,
        strumlineIndex:Int, columnIndex:Int, direction:String,
        notePath:String, noteXmlPath:String,
        holdPath:String, holdXmlPath:String,
        pixelsPerMs:Float)
    {
        super(0, 0);

        loadOffsetsIfNeeded();

        this.rawColumn = rawColumn;
        this.strumTime = strumTime;
        this.noteType = noteType;
        this.sustainEnd = sustainEnd;
        this.strumlineIndex = strumlineIndex;
        this.columnIndex = columnIndex;
        this.direction = direction;

        this.isSustain = (noteType == 2 && sustainEnd > strumTime);
        this.sustainLength = isSustain ? (sustainEnd - strumTime) : 0;

        configureHead(notePath, noteXmlPath);

        if (isSustain)
            buildSustainTrail(holdPath, holdXmlPath, pixelsPerMs);

        // added last so it draws on top of the sustain trail, not behind it
        add(head);
    }

    /**
     * Hides the note head sprite (e.g. once it's been hit) while leaving
     * the sustain trail visible so it can keep scrolling through as it's held.
     */
    public function hideHead():Void
    {
        if (head != null)
            head.visible = false;
    }

    /**
     * Call every frame (for sustain notes only) once the note has reached
     * the strum receptor. Rather than clipping the trail's texture, this
     * shrinks the loop piece's height down to 0 as it's consumed, then
     * shrinks the end cap the same way right after - matching how FNF
     * itself "eats" a hold note, instead of a straight scroll-through.
     *
     * songPos: current song time in ms.
     * noteSpeed: current pixels-per-ms scroll speed (same value used to
     * size the trail at construction, so the shrink rate matches the
     * scroll rate exactly).
     */
    /**
     * Re-syncs the trail's position against the head every frame. During
     * the approach phase this is technically redundant with Flixel's own
     * group-position propagation, but calling it explicitly here removes
     * any chance of the two mechanisms disagreeing - which is what caused
     * the trail to visibly jump right as a note reached the strum (the
     * exact moment updateSustainProgress() started being the one doing
     * the positioning instead of group propagation).
     */
    public function repositionTrail():Void
    {
        if (sustainLoop != null)
            positionSustainLoop();

        if (sustainEndCap != null)
            positionSustainEndCap();
    }

    public function updateSustainProgress(songPos:Float, noteSpeed:Float):Void
    {
        if (sustainLoop == null)
            return;

        var elapsed:Float = Math.max(0, songPos - strumTime);

        var endCapHeightPx:Float = (sustainEndCap != null) ? sustainEndCap.height : 0;
        var endCapConsumeMs:Float = (noteSpeed > 0.0001) ? endCapHeightPx / noteSpeed : 0;

        var loopConsumeDuration:Float = Math.max(0.0001, sustainLength - endCapConsumeMs);

        var loopRatio:Float = 1 - Math.min(1, elapsed / loopConsumeDuration);
        loopRatio = Math.max(0, loopRatio);

        sustainLoop.scale.y = fullLoopScaleY * loopRatio;
        sustainLoop.updateHitbox();
        positionSustainLoop();
        sustainLoop.visible = loopRatio > 0;

        if (sustainEndCap != null)
        {
            var capElapsed:Float = Math.max(0, elapsed - loopConsumeDuration);
            var capRatio:Float = 1 - Math.min(1, capElapsed / Math.max(0.0001, endCapConsumeMs));
            capRatio = Math.max(0, capRatio);

            sustainEndCap.scale.set(NOTE_SCALE, NOTE_SCALE * capRatio);
            sustainEndCap.updateHitbox();
            positionSustainEndCap();
            sustainEndCap.visible = capRatio > 0;
        }
    }

    static function getAtlas(imagePath:String, xmlPath:String):FlxAtlasFrames
    {
        var key = imagePath + "|" + xmlPath;

        if (!atlasCache.exists(key))
            atlasCache.set(key, FlxAtlasFrames.fromSparrow(imagePath, xmlPath));

        return atlasCache.get(key);
    }

    static function loadOffsetsIfNeeded():Void
    {
        if (offsetsLoaded)
            return;

        offsetsLoaded = true;

        noteOffsets =
        {
            "note": {
                left: {x: 0, y: 0}, down: {x: 0, y: 0}, up: {x: 0, y: 0}, right: {x: 0, y: 0}
            },
            "sustainLoop": {
                left: {x: 0, y: 0}, down: {x: 0, y: 0}, up: {x: 0, y: 0}, right: {x: 0, y: 0}
            }
        };

        var path = "assets/data/notes/NoteOffsets.json";

        if (Assets.exists(path))
        {
            try
            {
                var parsed:Dynamic = Json.parse(Assets.getText(path));

                var note = Reflect.field(parsed, "note");
                if (note != null)
                    Reflect.setField(noteOffsets, "note", note);

                var sustain = Reflect.field(parsed, "sustainLoop");
                if (sustain != null)
                    Reflect.setField(noteOffsets, "sustainLoop", sustain);
            }
            catch (e:Dynamic)
            {
                trace('Note: failed to parse NoteOffsets.json: $e');
            }
        }
    }

    function getStoredOffset(mode:String):{x:Float, y:Float}
    {
        var modeData = Reflect.field(noteOffsets, mode);
        if (modeData == null)
            return {x: 0, y: 0};

        var off = Reflect.field(modeData, direction);
        if (off == null)
            return {x: 0, y: 0};

        return off;
    }

    /**
     * Applies the head's own tuned offset. The head never gets rescaled
     * after construction, so Flixel's own .offset mechanism (used for
     * aligning frames within an animation) is safe to use here.
     */
    function applyHeadOffset():Void
    {
        var off = getStoredOffset("note");
        head.offset.set(off.x, off.y);
    }

    function configureHead(notePath:String, noteXmlPath:String):Void
    {
        head = new FlxSprite(0, 0);
        head.frames = getAtlas(notePath, noteXmlPath);
        // notes.xml only has a single frame per direction (e.g. "left0000"),
        // so this just displays statically rather than animating
        head.animation.addByPrefix("note", direction, 24, false);
        head.animation.play("note");
        head.antialiasing = true;
        head.scale.set(NOTE_SCALE, NOTE_SCALE);
        head.updateHitbox();
        applyHeadOffset();
        // NOTE: intentionally not added to the group here - see constructor,
        // it needs to be added last so it renders on top of the trail
    }

    /**
     * Positions the loop with its TOP anchored to the head and its tuned
     * offset applied as a direct position shift - NOT via sprite.offset.
     * The loop is scaled non-uniformly (stretched on Y), and Flixel's
     * updateHitbox() recalculates .offset every time to compensate for
     * that stretch so the sprite renders where x/y say it should. Setting
     * .offset ourselves after that would silently discard that
     * compensation and throw the sprite way off - that was the "sustain
     * is offset very wrong" bug. Shifting x/y directly sidesteps it
     * entirely and works the same regardless of current scale.
     */
    function positionSustainLoop():Void
    {
        var off = getStoredOffset("sustainLoop");
        // frameWidth (native, unscaled), not width - a sprite's true visual
        // center always sits at x + frameWidth/2 regardless of its current
        // scale (Flixel's updateHitbox() keeps it that way). Centering with
        // the scaled width instead reintroduces a scale-proportional bias.
        sustainLoop.x = head.x + (head.frameWidth - sustainLoop.frameWidth) / 2 + off.x;
        sustainLoop.y = head.y + head.height / 2 + off.y;
    }

    function positionSustainEndCap():Void
    {
        var off = getStoredOffset("sustainLoop");
        sustainEndCap.x = head.x + (head.frameWidth - sustainEndCap.frameWidth) / 2 + off.x;
        sustainEndCap.y = sustainLoop.y + sustainLoop.height;
    }

    function buildSustainTrail(holdPath:String, holdXmlPath:String, pixelsPerMs:Float):Void
    {
        var trailHeight:Float = sustainLength * pixelsPerMs;

        if (trailHeight <= 0)
            return;

        var atlas = getAtlas(holdPath, holdXmlPath);

        // the loop piece gets stretched to cover the hold's full length.
        // it trails "below" the head (i.e. toward where the note hasn't
        // scrolled in from yet), same side the head approaches from.
        sustainLoop = new FlxSprite(0, 0);
        sustainLoop.frames = atlas;
        sustainLoop.animation.addByPrefix("loop", direction + " sustain loop", 24, false);
        sustainLoop.animation.play("loop");
        sustainLoop.antialiasing = true;
        sustainLoop.scale.x = NOTE_SCALE;
        sustainLoop.scale.y = trailHeight / sustainLoop.frameHeight;
        fullLoopScaleY = sustainLoop.scale.y;
        sustainLoop.updateHitbox();
        positionSustainLoop();
        add(sustainLoop);

        sustainEndCap = new FlxSprite(0, 0);
        sustainEndCap.frames = atlas;
        sustainEndCap.animation.addByPrefix("end", direction + " sustain end", 24, false);
        sustainEndCap.animation.play("end");
        sustainEndCap.antialiasing = true;
        sustainEndCap.scale.set(NOTE_SCALE, NOTE_SCALE);
        sustainEndCap.updateHitbox();
        positionSustainEndCap();
        add(sustainEndCap);
    }
}
