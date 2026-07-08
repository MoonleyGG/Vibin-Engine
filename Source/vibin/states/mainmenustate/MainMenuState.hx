package vibin.states.mainmenustate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import vibin.backend.MusicBeatState; 
import vibin.util.SoundUtil;
import flixel.group.FlxGroup.FlxTypedGroup;
import vibin.states.mainmenustate.MenuButton;
import vibin.backend.Paths.*;

class MainMenuState extends MusicBeatState
{
    var bg:FlxSprite;
    var bgFlash:FlxSprite; 
    var camFollow:FlxObject; 
    var bannerArt:FlxSprite; 

    var selectedButton:Int = 0;
    public var menuItems:FlxTypedGroup<MenuButton>;

    override public function create():Void
    {
        SoundUtil.PlayMusic("freakyMenu", true, true);
        super.create(); 

        bg = new FlxSprite(0, 0, images + "menu/MainMenu/menuBG.png");
        bg.antialiasing = true;
        bg.scale.set(1.175, 1.175);
        bg.updateHitbox();
        bg.screenCenter(X);
        bg.scrollFactor.set(0, 0.225);
        bg.y = -65; 
        add(bg);

        bgFlash = new FlxSprite(0, 0, images + "menu/MainMenu/menuBGMagenta.png"); 
        bgFlash.antialiasing = true;
        bgFlash.screenCenter(X);
        bgFlash.scrollFactor.copyFrom(bg.scrollFactor);
        bgFlash.y = -5; 
        add(bgFlash);
        bgFlash.visible = false;

        camFollow = new FlxObject(0, 0, 1, 1);
        add(camFollow);

        menuItems = new FlxTypedGroup<MenuButton>();
        add(menuItems);

        FlxG.camera.follow(camFollow, null, 0.15);

        for (num => option in MenuButton.buttons)
        {
            var itemY:Float = (num * 140) + 90;
            itemY += (4 - MenuButton.buttons.length) * 40;

            var item:MenuButton = new MenuButton(75, itemY, option);
            item.ID = num; 
            menuItems.add(item); 
        }

        switchSelection(0, false);
    } 
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.UP) switchSelection(-1);
        if (FlxG.keys.justPressed.DOWN) switchSelection(1);

menuItems.forEach(function(item:MenuButton)
{
    if (FlxG.mouse.overlaps(item))
    {
        if (selectedButton != item.ID)
        {
            selectedButton = item.ID;
            switchSelection(0, true, true);
        }

        if (FlxG.mouse.justPressed)
        {
            selectCurrentButton();
        }
    }
});

        if (FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER)
        {
            selectCurrentButton();
        }
    }

    function switchSelection(change:Int = 0, playSound:Bool = true, forceSound:Bool = false)
{
    selectedButton += change;

    if (selectedButton < 0) selectedButton = MenuButton.buttons.length - 1;
    if (selectedButton >= MenuButton.buttons.length) selectedButton = 0;

    if (playSound && (change != 0 || forceSound)) 
    {
        SoundUtil.PlaySound("scrollMenu");
    }

    if (bannerArt != null && bannerArt.animation != null)
    {
        bannerArt.animation.play(cast MenuButton.buttons[selectedButton]);
    }

    menuItems.forEach(function(item:MenuButton)
    {
        if (item.ID == selectedButton)
        {
            item.select();
            camFollow.setPosition(FlxG.width / 2, item.getGraphicMidpoint().y);
        }
        else
        {
            item.idle();
        }
    });
}
    function selectCurrentButton()
    {
        SoundUtil.PlaySound("confirmMenu");
        
        menuItems.forEach(function(item:MenuButton) {
            if (item.ID == selectedButton) {
                item.activate();
            }
        });
    }
}
