package haxe3ds.services;

class NWMExt {
    /**
     * Initializes NWMEXT.
     */
    @:native("nwmExtInit")
    public static function init() {};

    /**
     * Exits NWMEXT.
     */
    @:native("nwmExtExit")
    public static function exit() {};

    /**
     * Turns wireless on or off.
     * @param enable true enables it, false disables it.
     */
    @:native("NWMEXT_ControlWirelessEnabled")
    public static function setWireless(enable:Bool) {};
}