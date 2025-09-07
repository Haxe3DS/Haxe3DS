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
     * Variable property for getting wireless.
     * 
     * `Get` will return the variable.
     * 
     * `Set` will call `NWMEXT_ControlWirelessEnabled` and sets it and returns the variable.
     */
    @:isVar public static var wireless(get, set):Bool;
    static function get_wireless():Bool {
        return wireless;
    }
    static function set_wireless(wireless:Bool):Bool {
        untyped __cpp__('NWMEXT_ControlWirelessEnabled(wireless)');
        return wireless;
    }
}