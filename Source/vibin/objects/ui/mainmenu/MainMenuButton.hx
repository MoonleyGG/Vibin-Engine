package vibin.objects.ui.mainmenu;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.io.Path;
import util.fileUtils.TxtSplitter;

class MainMenuButton extends FlxSprite 
{
    private static inline var ENV_PATH:String = "assets/images/menus/ui/";

    public function new(x:Float = 0, y:Float = 0, menuButton:String)
    {
        super(x, y);

        var imagePath:String = Path.join([ENV_PATH, menuButton + ".png"]);
        var xmlPath:String = Path.join([ENV_PATH, menuButton + ".xml"]);

        scale.set(0.75, 0.75);

        antialiasing = true;

        frames = FlxAtlasFrames.fromSparrow(imagePath, xmlPath);

        animation.addByPrefix("idle", menuButton + " idle", 24, true);
        animation.addByPrefix("selected", menuButton + " selected", 24, true);

        playAnim("idle");
    }

    public function playAnim(animName:String, force:Bool = false):Void
    {
        animation.play(animName, force);
        centerOffsets(); // son which one do i use 🙏
        centerOrigin();
    }
}