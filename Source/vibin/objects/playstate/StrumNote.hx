package vibin.objects.playstate;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

class StrumNote extends FlxSprite
{
    public var direction:String;
    public var noteOffsets:Dynamic;

    public function new(X:Float, Y:Float, imagePath:String, xmlPath:String, direction:String)
    {
        super(X, Y);

        this.direction = direction;

        loadNoteOffsets();

        frames = FlxAtlasFrames.fromSparrow(imagePath, xmlPath);

        animation.addByPrefix("static", direction + " static", 24, false);
        animation.addByPrefix("miss", direction + " miss", 24, false);
        animation.addByPrefix("hit", direction + " hit", 24, false);

        animation.play("static");

        antialiasing = true;

        scale.set(0.75, 0.75);
    }

    public function PlayAnimation(anim:String):Void
    {
        animation.play(anim);
        applyOffset(anim);
    }

    function applyOffset(anim:String):Void
    {
        var mode = Reflect.field(noteOffsets, anim);
        var off = Reflect.field(mode, direction);

        offset.set(off.x, off.y);
    }

        function loadNoteOffsets():Void
    {
        noteOffsets =
        {
            "static":
            {
                left:{x:0,y:0},
                down:{x:0,y:0},
                up:{x:0,y:0},
                right:{x:0,y:0}
            },

            "miss":
            {
                left:{x:0,y:0},
                down:{x:0,y:0},
                up:{x:0,y:0},
                right:{x:0,y:0}
            },

            "hit":
            {
                left:{x:0,y:0},
                down:{x:0,y:0},
                up:{x:0,y:0},
                right:{x:0,y:0}
            }
        };

        #if sys
        var path = "assets/data/notes/NoteOffsets.json";

        if (FileSystem.exists(path))
            noteOffsets = Json.parse(File.getContent(path));
        #end
}
}