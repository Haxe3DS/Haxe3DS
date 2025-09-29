package haxe3ds.services;

/**
 * NS (Nintendo Shell) service.
 */
class NS {
    /**
     * Initializes NS.
     */
    @:native("nsInit")
    public static function init() {};

    /**
     * Exits NS.
     */
    @:native("nsExit")
    public static function exit() {};

    /**
     * Reboots the system
     */
    @:native("NS_RebootSystem")
    public static function rebootSystem() {};

    /**
     * If called, force terminates the application and throws a popup being "An error has occurred, forcing the software to close. The system will now restart."
     * 
     * Wrapper of `PMApp:TerminateTitle`
     */
    @:native("NS_TerminateTitle")
    public static function terminate() {}
}