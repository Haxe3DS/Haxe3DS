package hx3ds;

@:cppInclude("3ds.h")
class AM {
    /**
     * Initializes AM. This doesn't initialize with "am:app", see amAppInit().
     */
    @:native("amInit")
    public static function init():Void {};

    /**
     * Initializes AM with a service which has access to the amapp-commands. This should only be used when using the amapp commands, not non-amapp AM commands.
     */
    @:native("amAppInit")
    public static function appInit():Void {};

    /**
     * Exits AM.
     */
    @:native("amExit")
    public static function exit():Void {};

    /**
     * Gets the number of tickets installed on the system.
     * @return Count of tickets found.
     */
    public static function getTicketCount():Int {
        var ret:UInt32 = 0;
        untyped __cpp__("AM_GetTicketCount(&ret)");
        return ret;
    }

    /**
     * Gets a 32-bit device-specific ID.
     * @return The current device ID.
     */
    public static function getDeviceID():UInt32 {
        var ret:UInt32 = 0;
        untyped __cpp__("AM_GetDeviceId(&ret)");
        return ret;
    }
}