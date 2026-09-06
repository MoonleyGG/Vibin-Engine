package vibin.backend.ui; // recycled v-slice script thanks fnf coders

import flixel.system.scaleModes.BaseScaleMode;

class FullScreenScaleMode extends BaseScaleMode
{
    override public function updateGameSize(Width:Int, Height:Int):Void
    {
        var targetHeight:Float = 720;
        var aspectRatio:Float = Width / Height;

        var newGameWidth:Int = Math.ceil(targetHeight * aspectRatio);

        // Update internal game resolution
        @:privateAccess
        FlxG.width = newGameWidth;

        // Calculate horizontal offset to center the base 1280 canvas
        var extraWidth:Float = newGameWidth - FlxG.initialWidth;
        var offsetX:Float = extraWidth * 0.5;

        if (FlxG.cameras != null)
        {
            for (camera in FlxG.cameras.list)
            {
                if (camera != null)
                {
                    camera.width = newGameWidth;
                    // Shift camera scroll to keep (0,0) centered relative to native 1280x720
                    camera.scroll.x = -offsetX;
                }
            }
        }

        scale.x = Width / FlxG.width;
        scale.y = Height / FlxG.height;

        gameSize.x = Width;
        gameSize.y = Height;

        offset.x = 0;
        offset.y = 0;
    }
}
