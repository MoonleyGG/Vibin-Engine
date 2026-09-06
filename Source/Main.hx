package;

import lime.system.System;
import flixel.FlxGame;
import flixel.FlxState;
#if hxvlc
import hxvlc.util.Handle;
#end
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import openfl.media.Video;
import openfl.net.NetStream;
/**
 * funkin imports
 */
 import vibin.backend.ui.FullScreenScaleMode;

/**
 * The main class which initializes HaxeFlixel and starts the game in its initial state.
 */
class Main extends Sprite
{
  var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
  var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
  var initialState:Class<FlxState> = vibin.InitState; // The FlxState the game starts with.
  var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
  var skipSplash:Bool = false; // Whether to skip the flixel splash screen that appears in release mode. i love this splash why would i ever hide it bro
  var framerate:Int = 60; //Preferences.unlockedFramerate ? 0 : Preferences.framerate;

  public function new()
  {
    super();
	
	init();
  }

  function init(?event:Event):Void
  {
    #if (!html5 && !mobile)
    // Force-kill the game to prevent background processing.
    openfl.Lib.application.onExit.add((_) ->
    {
      // Dispose of cached audio and textures.
      /*funkin.audio.FunkinSound.stopAllAudio(true, true);
      funkin.FunkinMemory.purgeCache(true);*/ // make this later

      // Dispose of any assets still in the OpenFL cache, just incase.
      openfl.Assets.cache.clear();

      trace(' EXITING Resources are disposed, Game is closing now.');

      Sys.exit(0);
    }, 99);
    #end

    setupGame();
  }

  function setupGame():Void
    {
      var game:FlxGame = new FlxGame(
        gameWidth,
        gameHeight,
        initialState,
        framerate,
        framerate,
        true,
        (FlxG.stage.window.fullscreen || false)
    );

    addChild(game);

    FlxG.scaleMode = new FullScreenScaleMode();
    
    #if !debug
    if (!skipSplash) {
      trace("title splash");
      FlxG.switchState(() -> new flixel.system.FlxSplash(
        () -> Type.createInstance(initialState, [])
      ));
    }
    #end
  }
}
