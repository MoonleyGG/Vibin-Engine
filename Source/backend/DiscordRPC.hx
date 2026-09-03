package backend;

#if desktop
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
import cpp.Callable;
import cpp.RawPointer;
import cpp.RawConstPointer;

class DiscordRPC {
    public static var isInitialized:Bool = false;

    public static function initialize(clientID:String):Void {
        if (isInitialized) return;

        // Construct struct directly instead of using .create()
        var handlers = new DiscordEventHandlers();
        
        // Wrap callback functions with Callable.fromStaticFunction
        handlers.ready = Callable.fromStaticFunction(onReady);
        handlers.disconnected = Callable.fromStaticFunction(onDisconnected);
        handlers.errored = Callable.fromStaticFunction(onError);

        // Pass Bool (true/false) for autoRegister instead of Int (1)
        Discord.Initialize(clientID, RawPointer.addressOf(handlers), true, null);
        isInitialized = true;
    }

    public static function changePresence(details:String, state:String, ?smallImageKey:String, ?hasStartTimestamp:Bool = false):Void {
        var startTimestamp:Float = hasStartTimestamp ? Date.now().getTime() / 1000 : 0;

        // Construct struct directly instead of using .create()
        var presence = new DiscordRichPresence();
        presence.details = details;
        presence.state = state;
        presence.largeImageKey = "icon";
        presence.largeImageText = "My Game";
        
        if (smallImageKey != null) {
            presence.smallImageKey = smallImageKey;
        }

        if (hasStartTimestamp) {
            presence.startTimestamp = Std.int(startTimestamp);
        }

        Discord.UpdatePresence(RawConstPointer.addressOf(presence));
    }

    public static function update():Void {
        #if DISCORD_DISABLE_IO_THREAD
        Discord.RunCallbacks();
        #end
    }

    public static function shutdown():Void {
        Discord.Shutdown();
        isInitialized = false;
    }

    private static function onReady(request:RawConstPointer<DiscordUser>):Void {
        trace("Discord RPC Ready!");
    }

    private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void {
        trace('Discord Disconnected: $errorCode - $message');
    }

    private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void {
        trace('Discord Error: $errorCode - $message');
    }
}
#end