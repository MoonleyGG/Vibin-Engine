package vibin.util;

import flixel.FlxG;
import flixel.FlxSprite;

class RatioUtil
{
    public static inline function x(ratio:Float):Float
    {
        return ratio * FlxG.width;
    }

    public static inline function y(ratio:Float):Float
    {
        return ratio * FlxG.height;
    }

    public static inline function centerX(obj:FlxSprite, ratio:Float):Float
    {
        return (ratio * FlxG.width) - (obj.width / 2);
    }
}