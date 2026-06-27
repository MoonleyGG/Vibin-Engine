package;

import flixel.FlxGame;
import openfl.display.Sprite;
import vibin.util.logging.AnsiTrace;
import vibin.states.titlestate.TitleState;

class Main extends Sprite
{
	public function new()
	{
		super();

		haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) {
            if (infos != null && infos.className.indexOf("flxanimate") != -1) {
                return;
            }

            #if sys
            Sys.println(infos.fileName + ":" + infos.lineNumber + ": " + Std.string(v));
            #else
            trace(v);
            #end
        };

		// Enable ANSI-colored trace output for the terminal.
		haxe.Log.trace = AnsiTrace.trace;
		addChild(new FlxGame(1280, 720, TitleState));
		#if debug
		AnsiTrace.traceBF();
		#end
	}
}
