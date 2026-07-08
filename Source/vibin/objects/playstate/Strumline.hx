package vibin.objects.playstate;

import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import vibin.util.RatioUtil;

class Strumline
{
    public static function create(container:FlxGroup, groups:Array<FlxSpriteGroup>, notes:Array<Array<StrumNote>>, strumlines:Int, ratios:Array<Float>, keyCount:Int, keyDirections:Array<String>, noteSpacing:Float, pathPrefix:String)
        {
            for (strum in 0...strumlines)
            {
                var group = new FlxSpriteGroup();

                container.add(group);
                groups.push(group);

                var strumNotes:Array<StrumNote> = [];

                for (i in 0...keyCount)
                {
                    var note = new StrumNote(
                        i * noteSpacing,
                        0,
                        pathPrefix + "StrumlineNotes.png",
                        pathPrefix + "StrumlineNotes.xml",
                        keyDirections[i].toLowerCase()
                    );

                    group.add(note);
                    strumNotes.push(note);
                }

                notes.push(strumNotes);

                var ratio:Float = 0.25;

                if (strum < ratios.length)
                    ratio = ratios[strum];

                group.x = RatioUtil.centerX(group, ratio);
                group.y = 50;
            }
        }
}