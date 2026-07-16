package vibin.states.playstate;

import lime.utils.Assets;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup;
import flixel.util.FlxAxes;
import flixel.graphics.frames.FlxAtlasFrames;

import StringTools;

import haxe.Json;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

// vibin engine stuff
import vibin.backend.MusicBeatState;
import vibin.states.editors.charteditorstate.ChartEditorState;
import vibin.states.playstate.Icon;
import vibin.states.playstate.LoadMetadata;
import vibin.states.editors.noteoffseteditorstate.NoteOffsetEditorState;
import vibin.util.SoundUtil;
import vibin.backend.Controls;
import vibin.backend.Paths.images;
import vibin.objects.playstate.StrumNote;
import vibin.util.RatioUtil;
import vibin.objects.playstate.Strumline;

import vibin.systems.playstate.InputSystem;
import vibin.backend.playstate.ChartLoader;
import vibin.backend.playstate.Accuracy;
import vibin.objects.playstate.Note;

class PlayState extends MusicBeatState
{
    var Strumlines:FlxGroup;
    var StrumlineGroups:Array<FlxSpriteGroup> = [];
    public var StrumlineNotes:Array<Array<StrumNote>> = [];

    var noteOffsets:Dynamic;

    public var keyCount:Int = 1;
    public var keyDirections:Array<String> = ["Left", "Down", "Up", "Right"];
    public var strumlines:Int = 2;
    var strumlineRatios:Array<Float> = [0.25, 0.75];
    var noteSpacing:Float = 121;

    // last strumline is the player-controlled one; everything else auto-hits (bot/opponent)
    public var playerStrumlineIndex:Int = 1;

    var noteGroup:FlxGroup;
    public var notes:Array<Note> = [];
    var pixelsPerMs:Float = 0.45; // base speed, multiplied by scrollSpeed
    var noteSpeed:Float = 0;

    public var accuracyTracker:Accuracy = new Accuracy();
    public var totalNotes:Int = 0;

    public var health:Float = 0.5;
    public var score:Int = 0;
    public var misses:Int = 0;

    // metadata
    public var player:String = "Boyfriend"; // default option
    public var opponent:String = "Dad"; // ditto
    public var song:String = "bopeebo";

    public var scrollSpeed:Float = 2.0;
    
    override public function create():Void
    {
        loadMetadata();

        super.create();
        
        Strumlines = new FlxGroup();
        add(Strumlines);
        
        var pathPrefix:String = "assets/images/";
        if (images != null) {
            pathPrefix = images;
        }
        Strumline.create(Strumlines, StrumlineGroups, StrumlineNotes, strumlines, strumlineRatios, keyCount, keyDirections, noteSpacing, pathPrefix);

        playerStrumlineIndex = strumlines - 1;
        noteSpeed = pixelsPerMs * scrollSpeed;

        InputSystem.reset();

        noteGroup = new FlxGroup();
        add(noteGroup);

        notes = ChartLoader.createNotes(song, strumlines, keyCount, keyDirections, pathPrefix, noteSpeed);
        for (note in notes)
            noteGroup.add(note);

        totalNotes = 0;
        for (note in notes)
            if (note.strumlineIndex == playerStrumlineIndex)
                totalNotes++;

        var playerIcon = Icon.New(player, 0, 0, 0, 0.393);
        playerIcon.x = FlxG.width - playerIcon.width - 200; // 200 pixels from the right side of the screen
        playerIcon.y = FlxG.height / 2 - playerIcon.height / 2;

        var opponentIcon = Icon.New(opponent, 0, 0, 0, 0.393);
        opponentIcon.x = 200;
        opponentIcon.y = FlxG.height / 2 - opponentIcon.height / 2;
        opponentIcon.flipX = true;
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
            
        if (FlxG.keys.justPressed.NINE)
        {
            FlxG.switchState(new NoteOffsetEditorState());
            return;
        }

        health = flixel.math.FlxMath.bound(health, 0.0, 1.0);

        if (FlxG.keys.anyJustPressed([Controls.debugKey1]))
        {
            FlxG.switchState(new ChartEditorState());
        }

        if (health <= 0.1)
        {
            Icon.changeState(player, 2);
            Icon.changeState(opponent, 1);
        }

        if (health >= 0.9) // dont put this in an else if so it refreshes properly with modcharts
        {
            Icon.changeState(player, 1);
            Icon.changeState(opponent, 2);
        }

        if (health < 0.9 && health > 0.1)
        {
            Icon.changeState(player, 0);
            Icon.changeState(opponent, 0);
        }

        updateNotes();
    }

    function updateNotes():Void
    {
        var songPos:Float = 0;
        if (SoundUtil.currentMusic != null && SoundUtil.currentMusic.playing)
            songPos = SoundUtil.currentMusic.time;

        for (note in notes)
        {
            if (note.strumlineIndex < 0 || note.strumlineIndex >= StrumlineNotes.length)
                continue;

            var strumNotesForLine = StrumlineNotes[note.strumlineIndex];

            if (note.columnIndex < 0 || note.columnIndex >= strumNotesForLine.length)
                continue;

            var strumNote = strumNotesForLine[note.columnIndex];

            // a sprite's true visual center always sits at x + frameWidth/2
            // (Flixel's updateHitbox() keeps it there regardless of scale),
            // so centering against frameWidth/frameHeight - not the scaled
            // width/height - is what actually lines up two differently
            // scaled/sized atlases. Using scaled width reintroduces a
            // scale-proportional bias, which is why this was still
            // drifting slightly even after the two scales were unified.
            note.x = strumNote.x + (strumNote.frameWidth - note.head.frameWidth) / 2;
            var arrivalY:Float = strumNote.y + (strumNote.frameHeight - note.head.frameHeight) / 2;

            if (note.isSustain && songPos >= note.strumTime)
            {
                // pin the note's anchor at the strum once it arrives - the
                // sustain trail "eats" itself via updateSustainProgress()
                // instead of the whole note continuing to scroll upward
                // and getting visually clipped as it passes through.
                note.y = arrivalY;
                note.updateSustainProgress(songPos, noteSpeed);
            }
            else
            {
                note.y = arrivalY + (note.strumTime - songPos) * noteSpeed;

                if (note.isSustain)
                    note.repositionTrail();
            }

            note.visible = (note.y > -note.height) && (note.y < FlxG.height + note.height);
        }

        InputSystem.update(this, songPos);
    }

    override public function startSong():Void
    {
        if (!LoadMetadata.songMetadataAvailable)
        {
            return;
        }

        super.startSong();
        SoundUtil.PlaySong(song, false, 1, 0, -1, false);
    }

    override public function songBeatHit():Void
    {
        if (!LoadMetadata.songMetadataAvailable)
            return;

        super.songBeatHit();

        for (icon in Icon.registry)
        {
            icon.beat(beatStep);
        }
    }

    function loadMetadata():Void
    {
        LoadMetadata.loadSongMetadata(song, BPM);

        player = LoadMetadata.player;
        opponent = LoadMetadata.opponent;
        if (LoadMetadata.songMetadataAvailable) {
            BPM = LoadMetadata.bpm;
            keyCount = LoadMetadata.keyCount;
            scrollSpeed = LoadMetadata.scrollSpeed;
        }
    }
}
