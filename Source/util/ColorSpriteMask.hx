package util;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import openfl.display.BitmapData;

/**
 * Reveal a FlxText only where a specific color exists inside another sprite.
 *
 * This matches the actual use-case for the record-edge art: the mask is a
 * single target color in the source sprite, not an alpha transparency map.
 */
class ColorSpriteMask
{
    public var text:FlxText;
    public var source:FlxSprite;
    public var targetColor:Int;
    public var tolerance:Int;
    public var camera:FlxCamera;

    public function new(text:FlxText, source:FlxSprite, targetColor:Int, tolerance:Int = 32, ?camera:FlxCamera)
    {
        this.text = text;
        this.source = source;
        this.targetColor = targetColor;
        this.tolerance = tolerance;
        this.camera = camera != null ? camera : FlxG.camera;

        update();
    }

    public function update():Void
    {
        if (text == null || source == null)
            return;

        var textPixels:BitmapData = text.pixels;
        var sourcePixels:BitmapData = source.framePixels;
        if (textPixels == null || sourcePixels == null)
            return;

        var textData:BitmapData = textPixels.clone();
        var textScreen:flixel.math.FlxPoint = text.getScreenPosition(camera);
        var sourceScreen:flixel.math.FlxPoint = source.getScreenPosition(camera);

        for (y in 0...textData.height)
        {
            for (x in 0...textData.width)
            {
                var screenX:Int = Std.int(textScreen.x + x);
                var screenY:Int = Std.int(textScreen.y + y);
                var localX:Int = screenX - Std.int(sourceScreen.x);
                var localY:Int = screenY - Std.int(sourceScreen.y);

                if (localX < 0 || localY < 0 || localX >= sourcePixels.width || localY >= sourcePixels.height)
                {
                    textData.setPixel32(x, y, 0x00000000);
                    continue;
                }

                var maskColor:Int = sourcePixels.getPixel32(localX, localY);
                var r:Int = (maskColor >> 16) & 0xFF;
                var g:Int = (maskColor >> 8) & 0xFF;
                var b:Int = maskColor & 0xFF;
                var tr:Int = (targetColor >> 16) & 0xFF;
                var tg:Int = (targetColor >> 8) & 0xFF;
                var tb:Int = targetColor & 0xFF;

                var dr:Int = Std.int(Math.abs(r - tr));
                var dg:Int = Std.int(Math.abs(g - tg));
                var db:Int = Std.int(Math.abs(b - tb));

                if (dr > tolerance || dg > tolerance || db > tolerance)
                {
                    textData.setPixel32(x, y, 0x00000000);
                }
            }
        }

        text.pixels = textData;
        text.dirty = true;
    }

    public function setColor(color:Int):Void
    {
        targetColor = color;
        update();
    }

    public function setTolerance(value:Int):Void
    {
        tolerance = value;
        update();
    }

    public function destroy():Void
    {
        text = null;
        source = null;
    }
}
