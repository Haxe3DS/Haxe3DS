package haxe3ds.services;

/**
 * PTMU service.
 */
@:cppInclude("3ds.h")
class PTMU {
    /**
     * Initializes PTMU.
     */
    @:native("ptmuInit")
    public static function init() {};

    /**
     * Exits PTMU.
     */
    @:native("ptmuExit")
    public static function exit() {};

    /**
     * Variable property that gets the system's current shell state.
     * 
     * `Get` will call `PTMU_GetShellState` and checks if it returns 0.
     */
    public static var shellClosed(get, null):Bool;
    static function get_shellClosed():Bool {
        var out:UInt8 = 0;
        untyped __cpp__("PTMU_GetShellState(&out)");
        return out == 0;
    }

    /**
     * Variable property that gets the system's current battery level.
     * 
     * All types of battery levels:
     * - 5: 4 bars (100%-61%)
     * - 4: 3 bars (60%-31%)
     * - 3: 2 bars (30%-11%)
     * - 2: 1 bar (10%-6%)
     * - 1: 1 bar (5%-1%, flashing LED)
     * - 0: 0 bar (0%)
     * 
     * `Get` will call `PTMU_GetBatteryLevel` and will return the current battery level (0-5)
     */
    public static var batteryLevel(get, null):UInt8;
    static function get_batteryLevel():UInt8 {
        var ret:UInt8 = 0;
        untyped __cpp__("PTMU_GetBatteryLevel(&ret)");
        return ret;
    }

    /**
     * Variable property that gets the system's current battery charge state.
     * 
     * `Get` will call `PTMU_GetBatteryChargeState` and will return true if it's charging (value is 1), false if not.
     */
    public static var isCharging(get, null):Bool;
    static function get_isCharging():Bool {
        var out:UInt8 = 0;
        untyped __cpp__("PTMU_GetBatteryChargeState(&out)");
        return out == 1;
    }

    /**
     * Variable property that gets the system's current pedometer state.
     * 
     * Returns `true` when the pedometer is counting the number of steps; otherwise, returns `false`. 
     */
    public static var isWalking(get, null):Bool;
    static function get_isWalking():Bool {
        var out:UInt8 = 0;
        untyped __cpp__("PTMU_GetPedometerState(&out)");
        return out == 1;
    }

    /**
     * Gets the system's step count history by many hours ago.
     * @param hours Number of hours to get the step count history for.
     * @return The elapsed step count history by hours ago.
     */
    public static function getStepHistory(hours:UInt32):UInt16 {
        var ret:UInt16 = 0;
        untyped __cpp__("PTMU_GetStepHistory(hours, &ret)");
        return ret;
    }

    /**
     * Variable property that gets the pedometer's total step count.
     * 
     * This also can be viewed by going to `Activity Log` > `Top Screen saying "Steps Taken"`
     */
    public static var totalSteps(get, null):Int;
    static function get_totalSteps():Int {
        var out:UInt32 = 0;
        untyped __cpp__("PTMU_GetTotalStepCount(&out)");
        return out;
    }

    /**
     * Variable property that gets whether the adapter is plugged in or not.
     * 
     * `Get` will call `PTMU_GetAdapterState` and will return whetever if the adapter is plugged in or not.
     */
    public static var adapterState(get, null):Bool;
    static function get_adapterState():Bool {
        var out:Bool = false;
        untyped __cpp__("PTMU_GetAdapterState(&out)");
        return out;
    }
}