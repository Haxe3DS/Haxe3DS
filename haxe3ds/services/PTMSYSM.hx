package haxe3ds.services;

import haxe3ds.Types.Result;

/**
 * PTMSYSM service.
 * @since 1.1.0
 */
class PTMSYSM {
    /**
     * Initializes ptm:sysm.
     */
    @:native("ptmSysmInit")
    public static function init():Result {return 0;}

    /**
     * Exits ptm:sysm.
     */
    @:native("ptmSysmExit")
    public static function exit() {}

    /**
     * Requests to enter sleep mode.
     */
    @:native("PTMSYSM_RequestSleep")
    public static function requestSleep():Result {return 0;}

    /**
     * Clears the "step history".
     */
    @:native("PTMSYSM_ClearStepHistory")
    public static function clearStepHistory():Result {return 0;}

    /**
     * Clears the "play history".
     */
    @:native("PTMSYSM_ClearPlayHistory")
    public static function clearPlayHistory():Result {return 0;}

    /**
     * Invalidates the "system time" (cfg block 0x30002)
     */
    @:native("PTMSYSM_InvalidateSystemTime")
    public static function invalidateSystemTime():Result {return 0;}
}