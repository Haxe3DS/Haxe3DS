package hx3ds;

/**
 * PTMU service.
 */
@:cppInclude("3ds.h")
class PTMU {
    /**
     * Initializes PTMU.
     */
    @:native("ptmuInit")
    public static function init():Void {};

    /**
     * Exits PTMU.
     */
    @:native("ptmuExit")
    public static function exit():Void {};

    /**
     * Gets the system's current shell state.
     * @return true if Shell is closed, false if open.
     */
    public static function isShellClosed():Bool {
        var out:UInt8 = 0;
        untyped __cpp__("PTMU_GetShellState(&out)");
        return out == 0;
    }

    /**
     * Gets the system's current battery charge state.
     * @return true if it's charging, false if not.
     */
    public static function isCharging():Bool {
        var out:UInt8 = 0;
        untyped __cpp__("PTMU_GetBatteryChargeState(&out)");
        return out == 1;
    }

    /**
     * Gets the system's current pedometer state.
     * @return true if walking, false if not walking.
     */
    public static function isWalking():Bool {
        var out:UInt8 = 0;
        untyped __cpp__("PTMU_GetPedometerState(&out)");
        return out == 1;
    }

    /**
     * Gets the pedometer's total step count.
     * @return Pointer to write the total step count to.
     */
    public static function getTotalSteps():Int {
        var out:UInt32 = 0;
        untyped __cpp__("PTMU_GetTotalStepCount(&out)");
        return out;
    }
}