package vibin.states.editors.noteoffseteditorstate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

import haxe.Json;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if desktop
import openfl.net.FileReference;
#end

import vibin.backend.MusicBeatState;
import vibin.states.playstate.PlayState;

class NoteOffsetEditorState extends MusicBeatState
{
    //==================================================
    // Notes
    //==================================================

    var noteGroup:FlxSpriteGroup;

    var leftNote:FlxSprite;
    var downNote:FlxSprite;
    var upNote:FlxSprite;
    var rightNote:FlxSprite;

    var notes:Array<FlxSprite>;

    // falling-note (tap head) preview, one per direction - shown in "note" mode
    var fallingNoteSprites:Array<FlxSprite>;

    // sustain trail (hold loop) preview, one per direction - shown in "sustainLoop" mode
    var sustainLoopSprites:Array<FlxSprite>;

    // faint reference copy of the note head, shown only in "sustainLoop"
    // mode so the trail can be aligned against where the head actually
    // sits (including its own offset) instead of against the strum receptor
    var ghostHeadSprites:Array<FlxSprite>;

    //==================================================
    // UI
    //==================================================

    var infoText:FlxText;
    var helpText:FlxText;

    //==================================================
    // Selection
    //==================================================

    var selectedIndex:Int = 0;

    var noteNames:Array<String> =
    [
        "left",
        "down",
        "up",
        "right"
    ];

    var currentMode:String = "static";

    //==================================================
    // Offset data
    //==================================================

    var offsets:Dynamic;

    //==================================================
    // Controls
    //==================================================

    var moveAmount:Int = 1;

    override public function create():Void
{
    super.create();

    FlxG.mouse.visible = true;

    //==================================================
    // Load atlases
    //==================================================

    var atlas = FlxAtlasFrames.fromSparrow(
        "assets/images/StrumlineNotes.png",
        "assets/images/StrumlineNotes.xml"
    );

    var noteAtlas = FlxAtlasFrames.fromSparrow(
        "assets/images/notes.png",
        "assets/images/notes.xml"
    );

    var holdAtlas = FlxAtlasFrames.fromSparrow(
        "assets/images/NoteHoldAssets.png",
        "assets/images/NoteHoldAssets.xml"
    );

    //==================================================
    // Create strum receptor preview (static/miss/hit)
    //==================================================

    noteGroup = new FlxSpriteGroup();
    add(noteGroup);

    var spacing:Float = 157;

    leftNote = new FlxSprite(0 * spacing, 0);
    leftNote.frames = atlas;
    leftNote.animation.addByPrefix("static", "left static", 24, false);
    leftNote.animation.addByPrefix("miss", "left miss", 24, false);
    leftNote.animation.addByPrefix("hit", "left hit", 24, false);
    leftNote.animation.play("static");
    leftNote.antialiasing = true;
    leftNote.scale.set(0.75, 0.75);
    leftNote.updateHitbox();
    noteGroup.add(leftNote);

    downNote = new FlxSprite(1 * spacing, 0);
    downNote.frames = atlas;
    downNote.animation.addByPrefix("static", "down static", 24, false);
    downNote.animation.addByPrefix("miss", "down miss", 24, false);
    downNote.animation.addByPrefix("hit", "down hit", 24, false);
    downNote.animation.play("static");
    downNote.antialiasing = true;
    downNote.scale.set(0.75, 0.75);
    downNote.updateHitbox();
    noteGroup.add(downNote);

    upNote = new FlxSprite(2 * spacing, 0);
    upNote.frames = atlas;
    upNote.animation.addByPrefix("static", "up static", 24, false);
    upNote.animation.addByPrefix("miss", "up miss", 24, false);
    upNote.animation.addByPrefix("hit", "up hit", 24, false);
    upNote.animation.play("static");
    upNote.antialiasing = true;
    upNote.scale.set(0.75, 0.75);
    upNote.updateHitbox();
    noteGroup.add(upNote);

    rightNote = new FlxSprite(3 * spacing, 0);
    rightNote.frames = atlas;
    rightNote.animation.addByPrefix("static", "right static", 24, false);
    rightNote.animation.addByPrefix("miss", "right miss", 24, false);
    rightNote.animation.addByPrefix("hit", "right hit", 24, false);
    rightNote.animation.play("static");
    rightNote.antialiasing = true;
    rightNote.scale.set(0.75, 0.75);
    rightNote.updateHitbox();
    noteGroup.add(rightNote);

    noteGroup.screenCenter(FlxAxes.X);
    noteGroup.y = 120;

    notes = [
        leftNote,
        downNote,
        upNote,
        rightNote
    ];

    //==================================================
    // Create falling-note (tap head) preview
    //==================================================
    // positioned over the same columns as the strum preview above, using
    // noteGroup's already-centered x as the anchor (so they line up) -
    // added directly to the state rather than noteGroup, since adding to
    // an already-positioned group doesn't retroactively inherit its offset

    fallingNoteSprites = [];

    for (i in 0...noteNames.length)
    {
        var sprite = new FlxSprite(0, 0);
        sprite.frames = noteAtlas;
        sprite.animation.addByPrefix("note", noteNames[i], 24, false);
        sprite.animation.play("note");
        sprite.antialiasing = true;
        sprite.scale.set(0.75, 0.75); // matches Note.hx's actual gameplay scale
        sprite.updateHitbox();

        // center over the matching strum receptor - this is exactly the
        // formula PlayState uses (strumNote.x/y + (strumNote.w/h - note.w/h) / 2).
        // Placing raw sprites at the same column X as the strum preview
        // (like before) ignores that the two atlases are different native
        // sizes, so "looks aligned here" didn't mean "looks aligned in game".
        sprite.x = notes[i].x + (notes[i].width - sprite.width) / 2;
        sprite.y = notes[i].y + (notes[i].height - sprite.height) / 2;

        sprite.visible = false;
        add(sprite);
        fallingNoteSprites.push(sprite);
    }

    //==================================================
    // Ghost note head - reference only, shown in sustain mode so you're
    // aligning the trail against where the head actually sits (including
    // its own "note" offset), not against the strum receptor directly
    //==================================================

    ghostHeadSprites = [];

    for (i in 0...noteNames.length)
    {
        var sprite = new FlxSprite(0, 0);
        sprite.frames = noteAtlas;
        sprite.animation.addByPrefix("note", noteNames[i], 24, false);
        sprite.animation.play("note");
        sprite.antialiasing = true;
        sprite.scale.set(0.75, 0.75);
        sprite.updateHitbox();
        sprite.x = notes[i].x + (notes[i].width - sprite.width) / 2;
        sprite.y = notes[i].y + (notes[i].height - sprite.height) / 2;
        sprite.alpha = 0.35;
        sprite.visible = false;
        add(sprite);
        ghostHeadSprites.push(sprite);
    }

    //==================================================
    // Create sustain trail (hold loop) preview
    //==================================================
    // NOTE: in gameplay the loop's scale.y stretches per note to match
    // hold length, which also scales its Y offset proportionally. This
    // preview uses a fixed representative height, so the X offset here is
    // exact but the Y offset is only approximate - always spot check a
    // real hold note in-game after tuning.

    sustainLoopSprites = [];

    for (i in 0...noteNames.length)
    {
        var sprite = new FlxSprite(0, 0);
        sprite.frames = holdAtlas;
        sprite.animation.addByPrefix("loop", noteNames[i] + " sustain loop", 24, false);
        sprite.animation.play("loop");
        sprite.antialiasing = true;
        sprite.scale.set(0.75, 3); // tall preview stand-in for a stretched hold
        sprite.updateHitbox();

        // positioned relative to the ghost head using the exact same
        // formula Note.hx uses for the real sustain trail
        var ghost = ghostHeadSprites[i];
        sprite.x = ghost.x + (ghost.width - sprite.width) / 2;
        sprite.y = ghost.y + ghost.height / 2;

        sprite.visible = false;
        add(sprite);
        sustainLoopSprites.push(sprite);
    }

    //==================================================
    // Default offset data
    //==================================================

    offsets = {
        "static": {
            left:  {x: 0, y: 0},
            down:  {x: 0, y: 0},
            up:    {x: 0, y: 0},
            right: {x: 0, y: 0}
        },

        "miss": {
            left:  {x: 0, y: 0},
            down:  {x: 0, y: 0},
            up:    {x: 0, y: 0},
            right: {x: 0, y: 0}
        },

        "hit": {
            left:  {x: 0, y: 0},
            down:  {x: 0, y: 0},
            up:    {x: 0, y: 0},
            right: {x: 0, y: 0}
        },

        "note": {
            left:  {x: 0, y: 0},
            down:  {x: 0, y: 0},
            up:    {x: 0, y: 0},
            right: {x: 0, y: 0}
        },

        "sustainLoop": {
            left:  {x: 0, y: 0},
            down:  {x: 0, y: 0},
            up:    {x: 0, y: 0},
            right: {x: 0, y: 0}
        }
    };

    //==================================================
    // Load existing JSON if present
    //==================================================

    #if sys
    var path = "assets/data/notes/NoteOffsets.json";

    if (sys.FileSystem.exists(path))
    {
        try
        {
            offsets = haxe.Json.parse(sys.io.File.getContent(path));
        }
        catch (e:Dynamic)
        {
            trace("Couldn't load NoteOffsets.json");
        }
    }
    #end

    // older saved files won't have the newer "note"/"sustainLoop" keys -
    // patch them in so the editor doesn't crash switching to those modes
    ensureModeDefaults("static");
    ensureModeDefaults("miss");
    ensureModeDefaults("hit");
    ensureModeDefaults("note");
    ensureModeDefaults("sustainLoop");

    //==================================================
    // UI
    //==================================================

    infoText = new FlxText(10, 10, 0, "");
    infoText.setFormat(null, 18, FlxColor.WHITE);
    add(infoText);

    helpText = new FlxText(
        10,
        FlxG.height - 140,
        0,
        "1 Static\n2 Miss\n3 Hit\n4 Note\n5 Sustain\nA/D Select Note\nArrow Keys Move Offset\nShift = Move 10\nSpace Replay Animation\nE Export JSON\nESC Back"
    );

    helpText.setFormat(null, 16, FlxColor.GRAY);
    add(helpText);

    selectedIndex = 0;
    currentMode = "static";

    refreshVisibility();
    refreshSelection();
    refreshOffsets();
    refreshUI();
}

override public function update(elapsed:Float):Void
{
    super.update(elapsed);

    moveAmount = FlxG.keys.pressed.SHIFT ? 10 : 1;

    //==================================================
    // Change Mode
    //==================================================

    if (FlxG.keys.justPressed.ONE)
    {
        currentMode = "static";
        refreshVisibility();
        refreshSelection();
        refreshOffsets();
        refreshUI();
    }

    if (FlxG.keys.justPressed.TWO)
    {
        currentMode = "miss";
        refreshVisibility();
        refreshSelection();
        refreshOffsets();
        refreshUI();
    }

    if (FlxG.keys.justPressed.THREE)
    {
        currentMode = "hit";
        refreshVisibility();
        refreshSelection();
        refreshOffsets();
        refreshUI();
    }

    if (FlxG.keys.justPressed.FOUR)
    {
        currentMode = "note";
        refreshVisibility();
        refreshSelection();
        refreshOffsets();
        refreshUI();
    }

    if (FlxG.keys.justPressed.FIVE)
    {
        currentMode = "sustainLoop";
        refreshVisibility();
        refreshSelection();
        refreshOffsets();
        refreshUI();
    }

    //==================================================
    // Select Note
    //==================================================

    if (FlxG.keys.justPressed.A)
    {
        selectedIndex--;

        if (selectedIndex < 0)
            selectedIndex = notes.length - 1;

        refreshSelection();
        refreshUI();
    }

    if (FlxG.keys.justPressed.D)
    {
        selectedIndex++;

        if (selectedIndex >= notes.length)
            selectedIndex = 0;

        refreshSelection();
        refreshUI();
    }

    //==================================================
    // Replay Animation
    //==================================================

    if (FlxG.keys.justPressed.SPACE)
    {
        activeSprites()[selectedIndex].animation.play(activeAnimationName(), true);
    }

    //==================================================
    // Reset Offset
    //==================================================

    if (FlxG.keys.justPressed.R)
    {
        var data:Dynamic = Reflect.field(offsets, currentMode);
        var note:Dynamic = Reflect.field(data, noteNames[selectedIndex]);

        note.x = 0;
        note.y = 0;

        refreshOffsets();
        refreshUI();
    }

    //==================================================
    // Move Offset
    //==================================================

    var changed:Bool = false;

    var modeData:Dynamic = Reflect.field(offsets, currentMode);
    var offsetData:Dynamic = Reflect.field(modeData, noteNames[selectedIndex]);

    if (FlxG.keys.pressed.LEFT)
    {
        offsetData.x -= moveAmount;
        changed = true;
    }

    if (FlxG.keys.pressed.RIGHT)
    {
        offsetData.x += moveAmount;
        changed = true;
    }

    if (FlxG.keys.pressed.UP)
    {
        offsetData.y -= moveAmount;
        changed = true;
    }

    if (FlxG.keys.pressed.DOWN)
    {
        offsetData.y += moveAmount;
        changed = true;
    }

    if (changed)
    {
        refreshOffsets();
        refreshUI();
    }

    //==================================================
    // Export JSON
    //==================================================

    #if desktop
    if (FlxG.keys.justPressed.E)
    {
        var file = new FileReference();
        file.save(
            Json.stringify(offsets, "\t"),
            "NoteOffsets.json"
        );
    }
    #end

    //==================================================
    // Back
    //==================================================

    if (FlxG.keys.justPressed.ESCAPE)
    {
        FlxG.switchState(new PlayState());
    }
}

//==================================================
// Mode helpers
//==================================================

function isStrumMode():Bool
{
    return currentMode == "static" || currentMode == "miss" || currentMode == "hit";
}

function activeSprites():Array<FlxSprite>
{
    return switch (currentMode)
    {
        case "note": fallingNoteSprites;
        case "sustainLoop": sustainLoopSprites;
        default: notes;
    }
}

function activeAnimationName():String
{
    if (isStrumMode())
        return currentMode;

    return currentMode == "note" ? "note" : "loop";
}

function ensureModeDefaults(mode:String):Void
{
    if (Reflect.field(offsets, mode) != null)
        return;

    Reflect.setField(offsets, mode, {
        left:  {x: 0, y: 0},
        down:  {x: 0, y: 0},
        up:    {x: 0, y: 0},
        right: {x: 0, y: 0}
    });
}

function refreshVisibility():Void
{
    for (s in notes)
        s.visible = isStrumMode();

    for (s in fallingNoteSprites)
        s.visible = (currentMode == "note");

    for (s in sustainLoopSprites)
        s.visible = (currentMode == "sustainLoop");

    for (s in ghostHeadSprites)
        s.visible = (currentMode == "sustainLoop");
}

function refreshSelection():Void
{
    var sprites = activeSprites();

    for (i in 0...sprites.length)
    {
        sprites[i].color = (i == selectedIndex)
            ? FlxColor.YELLOW
            : FlxColor.WHITE;
    }

    sprites[selectedIndex].animation.play(activeAnimationName(), true);
}

function refreshOffsets():Void
{
    // ghost head always reflects the current "note" offset, regardless of
    // which mode we're in, so it's ready the moment sustain mode is entered
    var noteOffsetData:Dynamic = Reflect.field(offsets, "note");

    for (i in 0...ghostHeadSprites.length)
    {
        var ghost = ghostHeadSprites[i];
        var off = Reflect.field(noteOffsetData, noteNames[i]);
        ghost.offset.set(off.x, off.y);
    }

    if (currentMode == "sustainLoop")
    {
        var sustainOffsetData:Dynamic = Reflect.field(offsets, "sustainLoop");

        for (i in 0...sustainLoopSprites.length)
        {
            var sprite = sustainLoopSprites[i];
            var ghost = ghostHeadSprites[i];
            var off = Reflect.field(sustainOffsetData, noteNames[i]);

            sprite.animation.play("loop", true);

            // applied as a direct position shift, NOT sprite.offset - the
            // loop preview uses non-uniform scale (tall stretch), and
            // Flixel's updateHitbox() recalculates offset to compensate
            // for that stretch. Overwriting it via .offset silently
            // discards that compensation and throws the sprite way off,
            // which is exactly the "very wrong" position bug. Real hold
            // notes in Note.hx have the same fix.
            sprite.x = ghost.x + (ghost.width - sprite.width) / 2 + off.x;
            sprite.y = ghost.y + ghost.height / 2 + off.y;
        }

        refreshUI();
        return;
    }

    var sprites = activeSprites();

    for (i in 0...sprites.length)
    {
        var sprite = sprites[i];
        var noteName = noteNames[i];

        sprite.animation.play(activeAnimationName(), true);

        var modeData:Dynamic = Reflect.field(offsets, currentMode);
        var offsetData:Dynamic = Reflect.field(modeData, noteName);

        sprite.offset.set(offsetData.x, offsetData.y);
    }
}

function refreshUI():Void
{
    var modeData:Dynamic = Reflect.field(offsets, currentMode);
    var offsetData:Dynamic = Reflect.field(modeData, noteNames[selectedIndex]);

    var modeLabel = currentMode == "sustainLoop" ? "SUSTAIN" : currentMode.toUpperCase();

    infoText.text =
        "Mode: " + modeLabel + "\n" +
        "Selected: " + noteNames[selectedIndex].toUpperCase() + "\n\n" +
        "Offset X: " + offsetData.x + "\n" +
        "Offset Y: " + offsetData.y +
        (currentMode == "sustainLoop" ? "\n\n(Y offset is approximate here -\nactual hold height varies per note)" : "");
}
}
