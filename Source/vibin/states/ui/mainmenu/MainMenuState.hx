package vibin.states.ui.mainmenu;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import util.fileUtils.TxtSplitter;
import vibin.objects.ui.mainmenu.MainMenuButton;

import flixel.text.FlxText;
import openfl.filters.ShaderFilter;
import vibin.graphics.shaders.StrokeShader;

import openfl.Assets;
import openfl.filters.BlurFilter;
import openfl.filters.GlowFilter;
import openfl.display.BitmapData;
import openfl.display.Shader;

class MainMenuState extends MusicUIBeatState {
    //
    // object variables
    //
    var menuButtonGroup:FlxTypedGroup<MainMenuButton>; // does this count? i dont have anywere else to put it tho so ig
    var textGroup:FlxTypedGroup<FlxSprite>;

    var blurred:FlxText;
    var text:FlxText;
    var blurredMask:ColorSpriteMask;
    var textMask:ColorSpriteMask;

    var recordedge:FlxSprite;
    var vinyl:FlxSprite;
    var bg:FlxSprite;

    //
    // config
    //
     /**
      * the padding from the middle of the vinyl.
      * the lower the closer it is to the middle.
      */
     var buttonPadding:Float = 310;
     /**
      * the passive speed of the vinyl, higher = faster
      */
      var passiveSpeed:Float = 60;

      //
      // variables
      //
      var MenuButtons:Array<String> = [];

      var currentSelectionAngle:Float = 0;
      var targetSelectionAngle:Float = 0;
      var vinylSpinAngle:Float = 0;
      var curSelected:Int = 0;

      var updateElapsed:Float = 0; // i dont know how to make the shit work before this.

      //
      // tweens
      //
      var spinTween:FlxTween;

      override function create() {
        super.create();

        SoundUtil.playMusic("mainmenu", 1, true, false);
        
        /**
         * convert this to the most recurring color in the bg when i have made that system.
         */
        FlxG.cameras.bgColor = 0xFFfde871;
        
        setupDiscord();
        createText();
        setupSprites();
      }

      override function update(elapsed:Float) {
        super.update(elapsed);

        updateElapsed = elapsed;

        if (textMask != null)
            textMask.update();
        if (blurredMask != null)
            blurredMask.update();

        updateSprites();
        updateButtonPositions();
        checkControls();
      }

      function createText() {
        textGroup = new FlxTypedGroup<FlxSprite>();

        blurred = new FlxText(0, 0, 0, "Playing Ludum Dare prototype menu theme - Kawai Sprite", 30);
        blurred.font = "assets/fonts/5by7.ttf";
        blurred.color = 0x00CCFF;
        blurred.textField.filters = [
            new BlurFilter(4, 4, 2),
            new GlowFilter(0x00CCFF, 1, 5, 5, 2)
        ];

        text = new FlxText(0, 0, 0, "Playing Ludum Dare prototype menu theme - Kawai Sprite",30);
        text.font = "assets/fonts/5by7.ttf";
        text.color = 0xFFFFFF;
        text.textField.filters = [
            new GlowFilter(
                0x00CCFF,
                1,
                5,
                5,
                210,
            )
        ];
        text.scrollFactor.set(0, 0);
        blurred.scrollFactor.set(0, 0);
        text.visible = true;
        blurred.visible = true;
      }

      /**
       * custom functions
       */
      function setupDiscord():Void {
        /**
         * value 1: The main text
         * value 2: The State
         */
        DiscordRPC.changePresence("In the Menus", "Main Menu");
      }

      function setupMenuButtons() {
        menuButtonGroup = new FlxTypedGroup<MainMenuButton>();
        MenuButtons = TxtSplitter.SplitTxt("menus/ui/mainmenu/MainMenuButtons");

        for (i in 0...MenuButtons.length) {
            var menuButtonName:String = MenuButtons[i];
            if (menuButtonName == null || menuButtonName.trim() == "")
                continue;

            var button:MainMenuButton = new MainMenuButton(0, 0, menuButtonName);
            if (button == null)
                continue;

            button.scrollFactor.set(0, 0);
            menuButtonGroup.add(button);
        }

        if (menuButtonGroup == null || menuButtonGroup.members == null || menuButtonGroup.members.length == 0)
            return;

        updateButtonPositions();
        changeSelection(0); // make sure you have a selection from the start
    }

    function setupSprites() {
        bg = new FlxSprite(0, 0, "assets/images/menus/bg.png");
        bg.scrollFactor.set();

        recordedge = new FlxSprite(0, 0, "assets/images/menus/mainmenu/recordedge.png");
        recordedge.scrollFactor.set();
        recordedge.setPosition(FlxG.width - recordedge.width, FlxG.height - recordedge.height);

        vinyl = new FlxSprite(0, 0, "assets/images/menus/mainmenu/record.png");
        vinyl.scrollFactor.set();
        vinyl.centerOffsets();
        vinyl.centerOrigin();
        vinyl.setPosition(FlxG.width - vinyl.width, (FlxG.height - vinyl.height) / 2);

        textGroup.add(blurred);
        textGroup.add(text);

        if (recordedge != null)
        {
            var revealColor:Int = 0x171717;
            blurredMask = new ColorSpriteMask(blurred, recordedge, revealColor, 8);
            textMask = new ColorSpriteMask(text, recordedge, revealColor, 8);
        }

        add(textGroup);
        tweenText();

        setupMenuButtons();
        
        /**
         * add the sprites in proper order
         */
         add(bg);
         add(vinyl);
         add(menuButtonGroup);
         add(recordedge);
    }

    function checkControls() {
        if (Controls.downUI_P) {
            changeSelection(1);
        }
        if (Controls.upUI_P) {
            changeSelection(-1);
        }
        if (Controls.accept_P) {
            selectOption(curSelected);
        }
    }

    function updateButtonPositions() {
         // i know these arent buttons but bowomp
        if (recordedge == null || vinyl == null)
            return;

        text.y = recordedge.y + 652;
        blurred.y = recordedge.y + 652;

        if (menuButtonGroup == null || menuButtonGroup.members == null || menuButtonGroup.members.length == 0)
            return;

        var vinylCenterX:Float = vinyl.getGraphicMidpoint().x;
        var vinylCenterY:Float = vinyl.getGraphicMidpoint().y;
        var angleStep:Float = (Math.PI * 2) / menuButtonGroup.members.length;

        for (i in 0...menuButtonGroup.members.length) {
            var button:MainMenuButton = menuButtonGroup.members[i];
            if (button == null)
                continue;

            var selectionOffsetRad:Float = currentSelectionAngle * (Math.PI / 180);
            var placementAngle:Float = Math.PI + selectionOffsetRad - (i * angleStep);

            button.x = vinylCenterX + (Math.cos(placementAngle) * buttonPadding) - (button.width / 2);
            button.y = vinylCenterY + (Math.sin(placementAngle) * buttonPadding) - (button.height / 2);
            button.angle = (placementAngle * (180 / Math.PI)) - 180;
        }
    }

    function updateSprites() {
        recordedge.setPosition(FlxG.width - recordedge.width, FlxG.height - recordedge.height);

        bg.setGraphicSize(1280, 720);
        bg.updateHitbox();
        bg.x = 0;

        vinyl.x = FlxG.width - vinyl.width;
        vinyl.screenCenter(Y);
        vinylSpinAngle += passiveSpeed * updateElapsed;
        vinyl.angle = vinylSpinAngle + (currentSelectionAngle * 0.7);
    }

    function changeSelection(change:Int = 0) {
        if (MenuButtons.length == 0 || menuButtonGroup == null || menuButtonGroup.members.length == 0)
            return;

        curSelected += change; // spare **change** sir?

        if (curSelected < 0)
            curSelected = MenuButtons.length - 1;
        if (curSelected >= MenuButtons.length)
            curSelected = 0;

        var angleStepDeg:Float = 360 / menuButtonGroup.members.length;
        targetSelectionAngle = curSelected * angleStepDeg;

        if (spinTween != null)
            spinTween.cancel();

        spinTween = FlxTween.tween(this, {currentSelectionAngle: targetSelectionAngle}, 0.8, {ease:FlxEase.quintOut});

        if (change < 0) {
            FlxTween.num(passiveSpeed, 0, 0.3, {ease: FlxEase.sineOut}, function(val:Float) {
                passiveSpeed = val;
            });
            FlxTween.num(0, 60, 0.5, {ease: FlxEase.sineInOut, startDelay: 0.3}, function(val:Float) {
                passiveSpeed = val;
            });
        }

        for (i in 0...menuButtonGroup.members.length) {
            var button:MainMenuButton = menuButtonGroup.members[i];
            if (i == curSelected) {
                button.playAnim("selected");
            }
            else
            {
                button.playAnim("idle");
            }
        }
    }

    function tweenText():Void
    {
        text.x = recordedge.x + 1050;

        FlxTween.tween(text, {x: recordedge.x - 500}, 15, {
            ease: FlxEase.linear,
            onComplete: function(tween:FlxTween)
            {
                tweenText();
            }
        });
        blurred.x = recordedge.x + 1050;

        FlxTween.tween(blurred, {x: recordedge.x - 500}, 15, {
            ease: FlxEase.linear,
        });
    }

    function selectOption(change:Int = 0) {
        switch (change)
        {
            case 0: // storymode
                TransitionState.switchState(vibin.states.ui.mainmenu.MainMenuState);
            case 1: // freeplay
                TransitionState.switchState(vibin.states.ui.mainmenu.MainMenuState);
            case 2: // gallery
                TransitionState.switchState(vibin.states.ui.mainmenu.MainMenuState);
            case 3: // awards
                TransitionState.switchState(vibin.states.ui.mainmenu.MainMenuState);
            case 4: // options
                TransitionState.switchState(vibin.states.ui.mainmenu.MainMenuState);
            case 5: // credits
                TransitionState.switchState(vibin.states.ui.mainmenu.MainMenuState);
            default:
                trace("no menu option selected dumbass ;3");
        }
    }
}