package vibin.states.mainmenustate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxDestroyUtil;
import vibin.backend.Paths.*;

import 

enum abstract MenuButtonType(String) to String {
    var STORYMODE = "storymode";
    var FREEPLAY = "freeplay";
    var MERCH = "merch";
    var OPTIONS = "options";
    var CREDITS = "credits";
    var AWARDS = "awards";
}

class MenuButton extends FlxSprite
{
    public static var buttons:Array<MenuButtonType> = [STORYMODE, FREEPLAY, AWARDS, OPTIONS, CREDITS];

    public var type:MenuButtonType;
    public var onSelectCallback:Void->Void; // The action this button performs
    
    private var buttonPath:String = "assets/images/menu/MainMenu/buttons";

    public function new(x:Float, y:Float, type:MenuButtonType)
    {
        super(x, y);
        this.type = type;

        var name:String = cast type;

        frames = flixel.graphics.frames.FlxAtlasFrames.fromSparrow(
            buttonPath + "/" + name + ".png", 
            buttonPath + "/" + name + ".xml"
        );
        
        animation.addByPrefix('idle', 'idle', 24, true);
        animation.addByPrefix('selected', 'selected', 24, true);
        animation.play('idle');
        
        updateHitbox();
        antialiasing = true;
        scrollFactor.set(0.2, 0.2);

        // Assign what happens when this specific button type is activated
        switch (type)
        {
            case STORYMODE:
                // onSelectCallback = () -> FlxG.switchState(() -> new StoryMenuState());
            case FREEPLAY:
                // onSelectCallback = () -> FlxG.switchState(() -> new FreeplayState());
            case AWARDS:
                // onSelectCallback = () -> FlxG.switchState(() -> new AwardsState());
            case OPTIONS:
                // onSelectCallback = () -> FlxG.switchState(() -> new OptionsState());
            case CREDITS:
                // onSelectCallback = () -> FlxG.switchState(() -> new CreditsState());
            default:
                // onSelectCallback = () -> trace("No state assigned to button: " + type);
        }
    }

    public function select():Void
    {
        animation.play('selected');
        centerOffsets();
    }

    public function idle():Void
    {
        animation.play('idle');
        updateHitbox();
    }

    public function activate():Void
    {
        if (onSelectCallback != null)
        {
            onSelectCallback();
        }
    }

    override function destroy()
    {
        onSelectCallback = null;
        super.destroy();
    }
}