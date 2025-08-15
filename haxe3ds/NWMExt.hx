package haxe3ds;

class NWMExt {
    /**
     * Initializes NWMEXT.
     */
    @:native("nwmExtInit")
    public static function init():Void {};

    /**
     * Exits NWMEXT.
     */
    @:native("nwmExtExit")
    public static function exit():Void {};

    /**
     * Turns wireless on or off.
     * @param enable true enables it, false disables it.
     */
    @:native("NWMEXT_ControlWirelessEnabled")
    public static function setWirelessActive(enable:Bool):Void {};
}