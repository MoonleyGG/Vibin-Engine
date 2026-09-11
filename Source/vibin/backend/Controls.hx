package vibin.backend;

import flixel.FlxG;
import vibin.options.OptionControls;

class Controls {
    /**
     * "commands" :3
     */
    public static var leftUI_P(get, never):Bool;
    public static var downUI_P(get, never):Bool;
    public static var upUI_P(get, never):Bool;
    public static var rightUI_P(get, never):Bool;
    public static var accept_P(get, never):Bool;

    /**
     * the annoying ass functions that are needed. why cant flixel be easier
     */
    private static inline function get_leftUI_P():Bool return FlxG.keys.anyJustPressed(OptionControls.leftKeys);
    private static inline function get_downUI_P():Bool return FlxG.keys.anyJustPressed(OptionControls.downKeys);
    private static inline function get_upUI_P():Bool return FlxG.keys.anyJustPressed(OptionControls.upKeys);
    private static inline function get_rightUI_P():Bool return FlxG.keys.anyJustPressed(OptionControls.rightKeys);
    private static inline function get_accept_P():Bool return FlxG.keys.anyJustPressed(OptionControls.acceptKeys);
}