package vibin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import vibin.backend.MusicBeatState; 
import vibin.util.SoundUtil;
import vibin.objects.Alphabet;
import flxanimate.FlxAnimate;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

// the paths
import vibin.backend.Paths.*;

class TitleState extends MusicBeatState
{
    var ngLogo:FlxSprite;
    var fnfLogo:FlxSprite;
    
    var logo:FlxAnimate;
    var gf:FlxAnimate;
    var pressEnter:FlxAnimate;
    
    var allowedBeat:Bool = true;

    var done:Bool = false;
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
            
            gf = new FlxAnimate(0, 0, images + "menu/GF");
            gf.anim.addByAnimIndices('danceLeft', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 24); 
            gf.anim.addByAnimIndices('danceRight', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], 24);
            gf.antialiasing = true;
            gf.updateHitbox();
            gf.screenCenter(Y);
            gf.x = 900;
            add(gf);
            gf.visible = false;
            gf.anim.loopType = PlayOnce;

            logo = new FlxAnimate(0, 0, images + "menu/Logo");
            logo.anim.addBySymbol('idle', 'Bump', 24, false);
            logo.antialiasing = true;
            logo.updateHitbox();
            logo.x = 350;
            logo.y = 275;
            add(logo);
            logo.visible = false;

            pressEnter = new FlxAnimate(0, 0, images + "menu/PressEnter");
            pressEnter.anim.addBySymbol('idle', 'idle', 24, true); // todo: update the fla so the animation names are just idle
            pressEnter.anim.addBySymbol('selected', 'selected', 24, true); // todo: update the fla so the animation names are just selected
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
            else if ((FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed) && done == true)
            {
                pressEnter.anim.play('selected', true);
                FlxG.camera.flash(FlxColor.WHITE, 1);

                new FlxTimer().start(2, function(tmr:FlxTimer)
                {
                    FlxG.switchState(() -> new MainMenuState());
                });
            }
        }
        override public function beatHit():Void
            {
                super.beatHit();

                logo.anim.play('idle', true);
                
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

                        gf.updateAnimation(0);
                        logo.updateAnimation(0);

                        if (allowedBeat)
                        {
                            switch (curBeat)
                            {
                                case 1:
                                    Alphabet.MakeTitleText("Starrlight gaemes", 1);
                                case 3:
                                    Alphabet.MakeTitleText("presents", 2);
                                case 4:
                                    Alphabet.ClearTitleText();
                                case 5:
                                    Alphabet.MakeTitleText("Not in association", 1);
                                    Alphabet.MakeTitleText("with", 2);
                                case 7:
                                    if (ngLogo != null) ngLogo.visible = true;
                                    Alphabet.MakeTitleText("Newgrounds", 3);
                                case 8:
                                    if (ngLogo != null) ngLogo.visible = false;
                                    Alphabet.ClearTitleText();
                                case 9:
                                    Alphabet.MakeTitleText("Engine for", 1);
                                case 11:
                                    Alphabet.MakeTitleText("game below", 2);
                                    if (fnfLogo != null) fnfLogo.visible = true;
                                case 12:
                                    Alphabet.ClearTitleText();
                                    if (fnfLogo != null) fnfLogo.visible = false;
                                case 13:
                                    Alphabet.MakeTitleText("friday", 1);
                                case 14:
                                    Alphabet.MakeTitleText("night", 2);
                                case 15:
                                    Alphabet.MakeTitleText("funkin", 3);
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