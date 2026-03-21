package haxe3ds.services;

import cpp.UInt8;
import cpp.UInt16;
import cpp.UInt32;
import haxe3ds.types.Result;

/**
 * PTMU service.
 */
@:cppInclude("haxe3ds_Utils.h")
class PTMU {
	/**
	 * Initializes PTMU.
	 */
	public static function init():Result {
		return untyped __cpp__('ptmuInit()');
	}

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
		return untyped __cpp__("API_GETTER(u8, PTMU_GetShellState, 1) == 0");
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
		return untyped __cpp__("API_GETTER(u8, PTMU_GetBatteryLevel, 5)");
	}

	/**
	 * Variable property that gets the system's current battery charge state.
	 * 
	 * `Get` will call `PTMU_GetBatteryChargeState` and will return true if it's charging (value is 1), false if not.
	 */
	public static var isCharging(get, null):Bool;
	static function get_isCharging():Bool {
		return untyped __cpp__("API_GETTER(u8, PTMU_GetBatteryChargeState, 1)");
	}

	/**
	 * Variable property that gets the system's current pedometer state.
	 * 
	 * Returns `true` when the pedometer is counting the number of steps; otherwise, returns `false`. 
	 */
	public static var isWalking(get, null):Bool;
	static function get_isWalking():Bool {
		return untyped __cpp__("API_GETTER(u8, PTMU_GetPedometerState, 0)");
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
	public static var totalSteps(get, null):UInt32;
	static function get_totalSteps():UInt32 {
		return untyped __cpp__("API_GETTER(u32, PTMU_GetTotalStepCount, 0)");
	}

	/**
	 * Variable property that gets whether the adapter is plugged in or not.
	 * 
	 * `Get` will call `PTMU_GetAdapterState` and will return Whether if the adapter is plugged in or not.
	 */
	public static var adapterState(get, null):Bool;
	static function get_adapterState():Bool {
		return untyped __cpp__("API_GETTER(bool, PTMU_GetAdapterState, 0)");
	}
}

/**
 * PTMSYSM service.
 * @since 1.1.0
 */
@:cppInclude("3ds.h")
class PTMSYSM {
	/**
	 * Initializes ptm:sysm.
	 */
	public static function init():Result {
		return untyped __cpp__('ptmSysmInit');
	}

	/**
	 * Exits ptm:sysm.
	 */
	@:native("ptmSysmExit")
	public static function exit() {}

	/**
	 * Requests to enter sleep mode.
	 */
	public static function requestSleep():Result {
		return untyped __cpp__('PTMSYSM_RequestSleep()');
	}

	/**
	 * Clears the "step history".
	 */
	public static function clearStepHistory():Result {
		return untyped __cpp__('PTMSYSM_ClearStepHistory()');
	};

	/**
	 * Clears the "play history".
	 */
	public static function clearPlayHistory():Result {
		return untyped __cpp__('PTMSYSM_ClearPlayHistory()');
	}

	/**
	 * Invalidates the "system time" (cfg block 0x30002)
	 */
	public static function invalidateSystemTime():Result {
		return untyped __cpp__('PTMSYSM_InvalidateSystemTime()');
	}
}