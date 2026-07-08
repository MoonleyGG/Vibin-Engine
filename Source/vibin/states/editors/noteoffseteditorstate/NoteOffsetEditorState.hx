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
    // Load atlas
    //==================================================

    var atlas = FlxAtlasFrames.fromSparrow(
        "assets/images/StrumlineNotes.png",
        "assets/images/StrumlineNotes.xml"
    );

    //==================================================
    // Create notes
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
    noteGroup.add(leftNote);

    downNote = new FlxSprite(1 * spacing, 0);
    downNote.frames = atlas;
    downNote.animation.addByPrefix("static", "down static", 24, false);
    downNote.animation.addByPrefix("miss", "down miss", 24, false);
    downNote.animation.addByPrefix("hit", "down hit", 24, false);
    downNote.animation.play("static");
    noteGroup.add(downNote);

    upNote = new FlxSprite(2 * spacing, 0);
    upNote.frames = atlas;
    upNote.animation.addByPrefix("static", "up static", 24, false);
    upNote.animation.addByPrefix("miss", "up miss", 24, false);
    upNote.animation.addByPrefix("hit", "up hit", 24, false);
    upNote.animation.play("static");
    noteGroup.add(upNote);

    rightNote = new FlxSprite(3 * spacing, 0);
    rightNote.frames = atlas;
    rightNote.animation.addByPrefix("static", "right static", 24, false);
    rightNote.animation.addByPrefix("miss", "right miss", 24, false);
    rightNote.animation.addByPrefix("hit", "right hit", 24, false);
    rightNote.animation.play("static");
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

    //==================================================
    // UI
    //==================================================

    infoText = new FlxText(10, 10, 0, "");
    infoText.setFormat(null, 18, FlxColor.WHITE);
    add(infoText);

    helpText = new FlxText(
        10,
        FlxG.height - 120,
        0,
        "1 Static\n2 Miss\n3 Hit\nA/D Select Note\nArrow Keys Move Offset\nShift = Move 10\nSpace Replay Animation\nE Export JSON\nESC Back"
    );

    helpText.setFormat(null, 16, FlxColor.GRAY);
    add(helpText);

    selectedIndex = 0;
    currentMode = "static";

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
        refreshOffsets();
        refreshUI();
    }

    if (FlxG.keys.justPressed.TWO)
    {
        currentMode = "miss";
        refreshOffsets();
        refreshUI();
    }

    if (FlxG.keys.justPressed.THREE)
    {
        currentMode = "hit";
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
        notes[selectedIndex].animation.play(currentMode, true);
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

function refreshSelection():Void
{
    for (i in 0...notes.length)
    {
        notes[i].color = (i == selectedIndex)
            ? FlxColor.YELLOW
            : FlxColor.WHITE;
    }

    notes[selectedIndex].animation.play(currentMode, true);
}

function refreshOffsets():Void
{
    for (i in 0...notes.length)
    {
        var sprite = notes[i];
        var noteName = noteNames[i];

        sprite.animation.play(currentMode, true);

        var modeData:Dynamic = Reflect.field(offsets, currentMode);
        var offsetData:Dynamic = Reflect.field(modeData, noteName);

        sprite.offset.set(offsetData.x, offsetData.y);
    }
}

function refreshUI():Void
{
    var modeData:Dynamic = Reflect.field(offsets, currentMode);
    var offsetData:Dynamic = Reflect.field(modeData, noteNames[selectedIndex]);

    infoText.text =
        "Mode: " + currentMode.toUpperCase() + "\n" +
        "Selected: " + noteNames[selectedIndex].toUpperCase() + "\n\n" +
        "Offset X: " + offsetData.x + "\n" +
        "Offset Y: " + offsetData.y;
}
}