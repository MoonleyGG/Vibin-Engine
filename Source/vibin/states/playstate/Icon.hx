package vibin.states.playstate;

import flixel.FlxSprite;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import vibin.backend.Paths.*;

import haxe.ds.StringMap;

class Icon extends FlxSprite
{
    public static var registry:StringMap<Icon> = new StringMap<Icon>();

    var parts:Int = 1;
    var iconName:String;

    var baseScale:Float = 1;
    var beatLeft:Bool = false;

    // name: filename (without extension) inside assets/images/icons/
    // state: integer frame to show (0..parts-1)
    // x, y: position
    // scale: uniform scale
    public function new(name:String, state:Int = 0, x:Float = 0, y:Float = 0, scale:Float = 1)
    {
        super(x, y);

        iconName = name;
        var path = images + "icons/" + name + ".png";

        // Load temporarily to get raw dimensions
        var tmp:FlxSprite = new FlxSprite(0, 0, path);
        var w:Int = Std.int(tmp.width);
        var h:Int = Std.int(tmp.height);

        if (w <= 0) w = 1;
        if (h <= 0) h = w;

        // Determine parts based on width/height ratio.
        // If the icon is not wider than twice its height, use 2 vertical frames.
        // Otherwise use 3 vertical frames.
        if (w <= h * 2)
            parts = 2;
        else
            parts = 3;

        var frameW:Int = Std.int(w / parts);

        // Re-load sliced frames so FlxSprite.frames work correctly.
        // This will create horizontal frame slices of width=frameW, height=h.
        loadGraphic(path, true, frameW, h);

        // Clamp state.
        var s:Int = Std.int(state);
        if (s < 0) s = 0;
        if (s >= parts) s = parts - 1;

        // Create single-frame animations for each part and play requested state.
        for (i in 0...parts)
        {
            animation.add('state' + i, [i], 24, false);
        }
        animation.play('state' + s, true);

        this.scale.set(scale, scale);

        baseScale = scale;

        updateHitbox();
        antialiasing = true;

        centerOrigin();

        this.x = x;
        this.y = y;

        registry.set(name, this);
    }

    public static function New(name:String, state:Int = 0, x:Float = 0, y:Float = 0, scale:Float = 1):Icon
    {
        var icon = new Icon(name, state, x, y, scale);
        if (flixel.FlxG.state != null) flixel.FlxG.state.add(icon);
        return icon;
    }

    public function changeStateTo(state:Int):Void
    {
        var s = Std.int(state);
        if (s < 0) s = 0;
        if (s >= parts) s = parts - 1;
        animation.play('state' + s, true);
    }

    public static function changeState(name:String, state:Int):Void
    {
        var ic = registry.get(name);
        if (ic != null) ic.changeStateTo(state);
    }

    public function beat(duration:Float):Void
{
    beatLeft = !beatLeft;

    FlxTween.cancelTweensOf(this);
    FlxTween.cancelTweensOf(scale);

    angle = beatLeft ? -20 : 20;
var cx = getGraphicMidpoint().x;
var cy = getGraphicMidpoint().y;

scale.set(baseScale * 1.15, baseScale * 1.15);
updateHitbox();

setPosition(
    cx - width * 0.5,
    cy - height * 0.5
);

    FlxTween.tween(this, {angle: 0}, duration * 0.75, {
        ease: FlxEase.quadOut
    });

    FlxTween.tween(scale, {
        x: baseScale,
        y: baseScale
    }, duration * 0.75, {
        ease: FlxEase.quadOut,
onUpdate: function(_)
{
    var cx = getGraphicMidpoint().x;
    var cy = getGraphicMidpoint().y;

    updateHitbox();

    setPosition(
        cx - width * 0.5,
        cy - height * 0.5
    );
}
    });
}
}