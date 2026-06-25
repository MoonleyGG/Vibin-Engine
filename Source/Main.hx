package;

import flixel.FlxGame;
import openfl.display.Sprite;
import vibin.util.logging.AnsiTrace;
import vibin.states.TitleState;

class Main extends Sprite
{
	public function new()
	{
		super();

		// Enable ANSI-colored trace output for the terminal.
		haxe.Log.trace = AnsiTrace.trace;
		addChild(new FlxGame(1280, 720, TitleState));
		#if debug
		AnsiTrace.traceBF();
		#end
	}
}
