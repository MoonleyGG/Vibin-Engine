package vibin;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;

/**
 * Perform a bunch of game setup, then immediately transition to whatever state you linked.
 */
@:nullSafety
class InitState extends FlxState
{
   /**
    * which state to transfer to after the initialization.
    */
    var transState:Class<FlxState> = vibin.states.ui.mainmenu.MainMenuState;
   
   override public function create():Void
    {
        super.create();

        trace("loaded");
        // yo add like config and shit 😂
        /**
         * replace this with your discord bot app id if you are modding preferably
         */
        DiscordRPC.initialize("1545087548085510336");
        FlxG.autoPause = false;

        FlxG.switchState(() -> Type.createInstance(transState, []));
    }
}
