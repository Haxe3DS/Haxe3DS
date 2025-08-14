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
     * Gets the system's current battery level.
     * 
     * All types of battery levels:
     * - 5: 4 bars (100-61%)
     * - 4: 3 bars (60-31%)
     * - 3: 2 bars (30%-11%)
     * - 2: 1 bar (10%-6%)
     * - 1: 1 bar (5%-1%, flashing LED)
     * - 0: 0 bar (0%)
     * 
     * @return Current battery level (0-5)
     */
    public static function getBatteryLevel():UInt8 {
        var ret:UInt8 = 0;
        untyped __cpp__("PTMU_GetBatteryLevel(&ret)");
        return ret;
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
     * Gets the system's step count history.
     * @param hours Number of hours to get the step count history for.
     * @return The elapsed step count history.
     */
    public static function getStepHistory(hours:UInt32):UInt16 {
        var ret:UInt16 = 0;
        untyped __cpp__("PTMU_GetStepHistory(hours, &ret)");
        return ret;
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

    /**
     * Gets whether the adapter is plugged in or not
     * @return Whetever if the adapter is plugged in or not.
     */
    public static function getAdapterState():Bool {
        var out:Bool = false;
        untyped __cpp__("PTMU_GetAdapterState(&out)");
        return out;
    }
}