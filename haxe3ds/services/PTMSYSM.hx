package haxe3ds.services;

/**
 * PTMSYSM service.
 * @since 1.1.0
 */
class PTMSYSM {
    /**
     * Initializes ptm:sysm.
     */
    @:native("ptmSysmInit")
    public static function init() {}

    /**
     * Exits ptm:sysm.
     */
    @:native("ptmSysmExit")
    public static function exit() {}

    /**
     * Requests to enter sleep mode.
     */
    @:native("PTMSYSM_RequestSleep")
    public static function requestSleep() {}

    /**
     * Clear the "step history".
     */
    @:native("PTMSYSM_ClearStepHistory")
    public static function clearStepHistory() {}

    /**
     * Clear the "play history".
     */
    @:native("PTMSYSM_ClearPlayHistory")
    public static function clearPlayHistory() {}

    /**
     * Invalidates the "system time" (cfg block 0x30002)
     */
    @:native("PTMSYSM_InvalidateSystemTime")
    public static function invalidateSystemTime() {}
}