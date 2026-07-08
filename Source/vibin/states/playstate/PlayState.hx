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

class PlayState extends MusicBeatState
{
    var Strumlines:FlxGroup;
    var StrumlineGroups:Array<FlxSpriteGroup> = [];
    var StrumlineNotes:Array<Array<StrumNote>> = [];

    var noteOffsets:Dynamic;

    var keyCount:Int = 4;
    var keyDirections:Array<String> = ["Left", "Down", "Up", "Right"];
    var strumlines:Int = 2;
    var strumlineRatios:Array<Float> = [0.25, 0.75];

    // ugh
    public var health:Float = 0.5;
    public var score:Int = 0;
    public var misses:Int = 0;
    public var accuracy:Float = 0.0; // i hate this

    // metadata
    public var player:String = "Boyfriend"; // default option
    public var opponent:String = "Dad"; // ditto
    public var song:String = "bopeebo";
    
    override public function create()
        {
            super.create();
            
            Strumlines = new FlxGroup();
            add(Strumlines);
            
            var pathPrefix:String = "assets/images/";
            if (images != null) {
                pathPrefix = images;
            }
            Strumline.create(Strumlines, StrumlineGroups, StrumlineNotes, strumlines, strumlineRatios, keyCount, keyDirections, 121, pathPrefix);
            
            /*
            * i dont remember if these should be before super.create?
            * hopefully if so if i add them to a function and
            * call it before super.create() it works
            * */
            LoadMetadata.loadSongMetadata(song, BPM);

            player = LoadMetadata.player;
            opponent = LoadMetadata.opponent;
            if (LoadMetadata.songMetadataAvailable) {
                BPM = LoadMetadata.bpm;
            }

            var playerIcon = Icon.New(player, 0, 0, 0, 0.25);
            playerIcon.x = FlxG.width - playerIcon.width - 200; // why the -200, i forgot. oh wait its so its 200 pixels from the right
            playerIcon.y = FlxG.height / 2 - playerIcon.height / 2;

            var opponentIcon = Icon.New(opponent, 0, 0, 0, 0.25);
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

                if (health >= 0.9) // dont put this is an else if so it refreshed properly with modcharts
                {
                    Icon.changeState(player, 1);
                    Icon.changeState(opponent, 2);
                }

                if (health < 0.9 && health > 0.1)
                {
                    Icon.changeState(player, 0);
                    Icon.changeState(opponent, 0);
                }
            }

            override public function startSong():Void
            {
                if (!LoadMetadata.songMetadataAvailable)
                {
                    trace('Skipping startSong becouse metadata XML is missing');
                    return;
                }

                super.startSong();
                SoundUtil.PlaySong(song, false, 1, 0, -1, false);
            }

            override public function songBeatHit():Void
            {
                if (!LoadMetadata.songMetadataAvailable)
                    return;

                switch (songBeat)
                {
                    // add shit here
                }
            }
}