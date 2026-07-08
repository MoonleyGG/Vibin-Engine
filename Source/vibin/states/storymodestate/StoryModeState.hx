package vibin.states.storymodestate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import vibin.backend.MusicBeatState; 
import vibin.util.SoundUtil;
import flixel.group.FlxGroup.FlxTypedGroup;
import vibin.states.mainmenustate.MenuButton;
import vibin.backend.Paths.*;
import vibin.states.playstate.PlayState;

class StoryModeState extends MusicBeatState
{
    var weekArt:FlxSprite;

    var difficulties:FlxSprite;
    var difficultiesArrows:FlxSprite;

    var weekSelected:Bool = true;
    var pressingArrow:Bool = false; // ughhhh im so bad at coding i have no idea how to make it so it doesnt play the not selected animation when you dont hold down the arrow keys :sob:D:\Videos\Ny mapp\right

    var selectedWeek:Int = 0;
    var selectedDifficulty:Int = 2; // 0 = easy, 1 = normal, 2 = hard, 3 = erect, 4 = nightmare
    var weekAnimations:Array<String> = ["week1", "week2", "week3"];
    var difficultyAnimations:Array<String> = ["Easy", "Normal", "Hard", "Erect", "Nightmare"];
    
    override public function create():Void
    {
        SoundUtil.StopMusic("freakyMenu", true);
        SoundUtil.PlaySong("bopeebo/Inst", true, 1, 0, 77, true);

        super.create();

        var weekArtPath = images + "menu/StoryMode/WeekArt";

        weekArt = new FlxSprite(0, 0);
        weekArt.frames = flixel.graphics.frames.FlxAtlasFrames.fromSparrow(weekArtPath + ".png", weekArtPath + ".xml");
        weekArt.animation.addByIndices('week1', 'WeekArt', [0], "", 24, true);
        weekArt.animation.addByIndices('week2', 'WeekArt', [1], "", 24, true);
        weekArt.animation.addByIndices('week3', 'WeekArt', [2], "", 24, true);
        weekArt.animation.play(weekAnimations[selectedWeek]);
        weekArt.updateHitbox();
        weekArt.scrollFactor.set();
        weekArt.screenCenter();
        weekArt.antialiasing = true;
        add(weekArt);

        difficulties = new FlxSprite(0, 0);
        difficulties.frames = flixel.graphics.frames.FlxAtlasFrames.fromSparrow("assets/images/menu/Difficulties.png", "assets/images/menu/Difficulties.xml");
        difficulties.animation.addByPrefix('Easy', 'Easy', 24, true);
        difficulties.animation.addByPrefix('Normal', 'Normal', 24, true);
        difficulties.animation.addByPrefix('Hard', 'Hard', 24, true);
        difficulties.animation.addByPrefix('Erect', 'Erect', 24, true);
        difficulties.animation.addByPrefix('Nightmare', 'Nightmare', 24, true);
        difficulties.animation.play(difficultyAnimations[selectedDifficulty]);
        difficulties.antialiasing = true;
        difficulties.screenCenter(Y);
        difficulties.x = 100;
        add(difficulties);

        difficultiesArrows = new FlxSprite(0, 0);
        difficultiesArrows.frames = flixel.graphics.frames.FlxAtlasFrames.fromSparrow("assets/images/menu/Arrows.png", "assets/images/menu/Arrows.xml");
        difficultiesArrows.animation.addByIndices('None', 'Arrows', [0], "", 24, true);
        difficultiesArrows.animation.addByIndices('Bottom', 'Arrows', [1], "", 24, true);
        difficultiesArrows.animation.addByIndices('Top', 'Arrows', [2], "", 24, true);
        difficultiesArrows.animation.addByIndices('Both', 'Arrows', [3], "", 24, true);
        difficultiesArrows.animation.play('None');
        difficultiesArrows.antialiasing = true;
        difficultiesArrows.screenCenter(Y);
        difficultiesArrows.x = 100;
        add(difficultiesArrows);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (weekSelected)
        {
            var downHeld = FlxG.keys.pressed.DOWN;
            var upHeld = FlxG.keys.pressed.UP;
            var downPressed = FlxG.keys.justPressed.DOWN;
            var upPressed = FlxG.keys.justPressed.UP;
            var leftPressed = FlxG.keys.justPressed.LEFT;
            var rightPressed = FlxG.keys.justPressed.RIGHT;
            var enterPressed = FlxG.keys.justPressed.ENTER;

            if (upHeld && downHeld)
            {
                difficultiesArrows.animation.play('Both');
                pressingArrow = true;
            }
            else if (downHeld)
            {
                difficultiesArrows.animation.play('Bottom');
                pressingArrow = true;
            }
            else if (upHeld)
            {
                difficultiesArrows.animation.play('Top');
                pressingArrow = true;
            }
            else
            {
                difficultiesArrows.animation.play('None');
                pressingArrow = false;
            }

            if (downPressed && selectedDifficulty < difficultyAnimations.length - 1)
            {
                selectedDifficulty++;
                difficulties.animation.play(difficultyAnimations[selectedDifficulty]);
            }
            else if (upPressed && selectedDifficulty > 0)
            {
                selectedDifficulty--;
                difficulties.animation.play(difficultyAnimations[selectedDifficulty]);
            }

            if (rightPressed && selectedWeek < weekAnimations.length - 1)
            {
                selectedWeek++;
                weekArt.animation.play(weekAnimations[selectedWeek]);
            }
            else if (leftPressed && selectedWeek > 0)
            {
                selectedWeek--;
                weekArt.animation.play(weekAnimations[selectedWeek]);
            }
        }
        else
        {
            difficultiesArrows.animation.play('None');
            pressingArrow = false;
        }

        if (FlxG.keys.justPressed.ENTER)
        {
            // SoundUtil.StopSong(false);
            // make like a 5 frame delay before switching to the playstate so the music can fade out
            new FlxTimer().start(10.0 / 60.0, function(tmr:FlxTimer)
            {
                FlxG.switchState(() -> new PlayState());
            });
        }
    }
}
