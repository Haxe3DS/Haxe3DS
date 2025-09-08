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
     * Variable property for settings wireless.
     * 
     * `Set` will call `NWMEXT_ControlWirelessEnabled` and sets it and returns the variable.
     */
    @:isVar public static var wireless(null, set):Bool;
    static function set_wireless(wireless:Bool):Bool {
        untyped __cpp__('NWMEXT_ControlWirelessEnabled(wireless)');
        return wireless;
    }
}