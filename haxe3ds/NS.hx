package haxe3ds;

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
}