package vibin.states.titlestate;

import flixel.FlxG;
import flixel.FlxSprite;
import vibin.backend.MusicBeatState; 
import vibin.util.SoundUtil;
import vibin.objects.Alphabet;
import flxanimate.FlxAnimate;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase; // If this still errors, change to: flixel.tweens.misc.FlxEase

// the paths
import vibin.backend.Paths.*;
import vibin.states.titlestate.TextShit.*;
import vibin.states.mainmenustate.MainMenuState;

class TitleState extends MusicBeatState
{
    var ngLogo:FlxSprite;
    var fnfLogo:FlxSprite;

    var logo:FlxAnimate;
    var gf:FlxAnimate;
    var pressEnter:FlxAnimate;

    var allowedBeat:Bool = true;
    var done:Bool = false;

    var secretCombo:Array<flixel.input.keyboard.FlxKey> = [UP, UP, DOWN, DOWN, LEFT, RIGHT, LEFT, RIGHT, B, A, SPACE];
    var playerInput:Array<flixel.input.keyboard.FlxKey> = [];

    override public function create():Void
    {
        SoundUtil.PlayMusic("freakyMenu", true, true);

        super.create();

        trace("TitleState initialized with BPM: " + BPM);
        
        ngLogo = new FlxSprite(0, 0, images + "logo/NewgroundsLogo.png");
        ngLogo.scale.set(0.8, 0.8);
        ngLogo.updateHitbox();
        ngLogo.screenCenter(X);
        ngLogo.y = 380;
        ngLogo.antialiasing = true;
        add(ngLogo);
        ngLogo.visible = false;
        
        fnfLogo = new FlxSprite(0, 0, images + "logo/FNFlogo.png");
        fnfLogo.scale.set(0.8, 0.8);
        fnfLogo.updateHitbox();
        fnfLogo.screenCenter(X);
        fnfLogo.antialiasing = true;
        fnfLogo.y = 320;
        add(fnfLogo);
        fnfLogo.visible = false;
        
        gf = new FlxAnimate(0, 0, images + "menu/title/GF");
        gf.anim.addByAnimIndices('danceLeft', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 24);
        gf.anim.addByAnimIndices('danceRight', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], 24);
        gf.antialiasing = true;
        gf.updateHitbox();
        gf.screenCenter(Y);
        gf.x = 900;
        add(gf);
        gf.visible = false;
        gf.anim.loopType = PlayOnce;

        logo = new FlxAnimate(0, 0, images + "menu/title/Logo");
        logo.anim.addBySymbol('idle', 'Bump', 24, false);
        logo.antialiasing = true;
        logo.updateHitbox();
        logo.x = 350;
        logo.y = 275;
        add(logo);
        logo.visible = false;

        pressEnter = new FlxAnimate(0, 0, images + "menu/title/PressEnter");
        pressEnter.anim.addBySymbol('idle', 'idle', 24, true); 
        pressEnter.anim.addBySymbol('selected', 'selected', 24, true); 
        pressEnter.antialiasing = true;
        pressEnter.updateHitbox();
        pressEnter.screenCenter(X);
        pressEnter.y = 675;
        add(pressEnter);
        pressEnter.visible = false;
        pressEnter.anim.play('idle', true);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if ((FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed) && done == false)
        {
            finishIntro();
        }
        else if ((FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed) && done == true)
        {
            pressEnter.anim.play('selected', true);
            FlxG.camera.flash(FlxColor.WHITE, 1);

            SoundUtil.PlaySound("confirmMenu");

            new FlxTimer().start(2, function(tmr:FlxTimer)
            {
                FlxG.switchState(() -> new MainMenuState());
            });
        }

        // FIX: Spelled 'lastKey' right
        var lastKey = FlxG.keys.firstJustPressed();

// In HaxeFlixel, if no key is pressed, firstJustPressed() returns -1 or 0
if (lastKey > 0)
{
    playerInput.push(lastKey);

    if (playerInput.length > secretCombo.length) {
        playerInput.shift();
    }

    if (checkComboMatch())
    {
        playerInput = [];
        activateSecretCode();
    }
}
    }

    function checkComboMatch():Bool
    {
        if (playerInput.length != secretCombo.length) return false;

        for (i in 0...secretCombo.length)
        {
            if (playerInput[i] != secretCombo[i]) {
                return false; 
            }
        }

        return true; 
    }

    function activateSecretCode():Void
    {
        SoundUtil.PlaySound("CS_confirm"); 
        trace("Swing thing");

        FlxTween.cancelTweensOf(FlxG.stage.window, ['x', 'y']);
        FlxTween.tween(FlxG.stage.window, {x: FlxG.stage.window.x + 300}, 1.4, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.35});
        FlxTween.tween(FlxG.stage.window, {y: FlxG.stage.window.y + 100}, 0.7, {ease: FlxEase.quadInOut, type: PINGPONG});
    }

    override public function beatHit():Void
    {
        super.beatHit();

        if (logo != null && logo.anim != null) logo.anim.play('idle', true);
        
        if (gf != null && gf.anim != null)
        {
            if (curBeat % 2 == 0)
            {
                gf.anim.play('danceLeft', true);
            }
            else
            {
                gf.anim.play('danceRight', true);
            }
        }

        if (gf != null) gf.updateAnimation(0);
        if (logo != null) logo.updateAnimation(0);

        if (allowedBeat)
        {
            switch (curBeat)
            {
                case 1:
                    Alphabet.MakeTitleText(textShit[0], 1); 
                case 3:
                    Alphabet.MakeTitleText(textShit[1], 2); 
                case 4:
                    Alphabet.ClearTitleText();
                case 5:
                    Alphabet.MakeTitleText(textShit[2], 1); 
                    Alphabet.MakeTitleText(textShit[3], 2); 
                case 7:
                    if (ngLogo != null) ngLogo.visible = true;
                    Alphabet.MakeTitleText(textShit[4], 3); 
                case 8:
                    if (ngLogo != null) ngLogo.visible = false;
                    Alphabet.ClearTitleText();
                case 9:
                    Alphabet.MakeTitleText(textShit[5], 1); 
                case 11:
                    Alphabet.MakeTitleText(textShit[6], 2); 
                    if (fnfLogo != null) fnfLogo.visible = true;
                case 12:
                    Alphabet.ClearTitleText();
                    if (fnfLogo != null) fnfLogo.visible = false;
                case 13:
                    Alphabet.MakeTitleText(textShit[7], 1); 
                case 14:
                    Alphabet.MakeTitleText(textShit[8], 2); 
                case 15:
                    Alphabet.MakeTitleText(textShit[9], 3); 
                case 16:
                    finishIntro();
            }
        }
    }
        
    function finishIntro():Void
    {
        Alphabet.ClearTitleText();
        gf.visible = true;
        logo.visible = true;
        pressEnter.visible = true;

        FlxG.camera.flash(FlxColor.WHITE, 1);
        allowedBeat = false;
        done = true;
    }
}