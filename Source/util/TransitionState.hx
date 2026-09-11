package util;

class TransitionState
{
    public static var fallbackState:Class<FlxState> = vibin.states.ui.mainmenu.MainMenuState;

    public static function switchState(state:Class<FlxState>):Void
    {
        if (state == null)
        {
            trace("transitionState was null using fallback state");
            return FlxG.switchState(() -> Type.createInstance(fallbackState, []));
        }

        trace("transitioning to " + state + " :3");
        return FlxG.switchState(() -> Type.createInstance(state, []));
    }
}
