package haxe3ds;

import haxe3ds.Types.Result;
import cpp.UInt64;

/**
 * The reason on why the program has to break.
 * @since 1.7.0
 */
enum abstract SVCUserBreakType(Int) {
	/**
	 * Panic.
	 */
	var PANIC;

	/**
	 * Assert.
	 */
	var ASSERT;

	/**
	 * User.
	 */
	var USER;
}

/**
 * System Call Wrappers
 * 
 * This is for advanced users, even tho this is a work in progress, it's more likely to be an useless class
 * if you don't know what you're doing.
 * 
 * @since 1.7.0
 */
@:cppInclude("3ds.h")
class SVC {
	/**
	 * Sleeps the program passed by how many Nanoseconds, This does the same thing as [`Sys.sleep`](https://api.haxe.org/Sys.html#sleep).
	 * @param ns Time to sleep in Nanoseconds.
	 */
	public static function sleep(ns:UInt64) {
		untyped __cpp__('svcSleepThread({0})', ns.toInt());
	}

	/**
	 * A setter variable that sets if you wanna Enable or Disable the WiFi
	 * 
	 * This function Requires 3DS version 11.4+ or higher, use this gist as an example:
	 * ```
	 * if (OS.versionToInt(OS.version) >= 1140000) {
	 *	SVC.wifiEnabled = true;
	 * } else {
	 * 	trace("Cannot Enable wifiEnabled");
	 * }
	 * ```
	 * 
	 * Like what NVM did, this does the following:
	 * ```
	 * if (in_flag)
	 *	 CFG11_WIFICNT |= 1;
	 * else
	 *	 CFG11_WIFICNT &= ~1;
	 * ```
	 * 
	 * @see https://www.3dbrew.org/wiki/SVC#svc_0x5A
	 */
	public static var wifiEnabled(default, set):Bool;
	static function set_wifiEnabled(wifiEnabled:Bool):Bool {
		return untyped __cpp__('svcSetWifiEnabled(wifiEnabled)');
	}

	/**
	 * Breaks the Execution (And maybe throws an Uncatchable Exception).
	 * @param type The reason on why you want to break.
	 */
	public static function breakExecution(type:SVCUserBreakType) {
		untyped __cpp__('svcBreak((UserBreakType)type)');
	}

	/**
	 * Outputs Debug String only available for Dev Console Unit, or have the `Trace` logging for emulator.
	 * @param str String to trace in the console.
	 * @return Result to indicate if something went wrong.
	 */
	public static function debugString(str:String):Result {
		return untyped __cpp__('svcOutputDebugString(str.c_str(), str.length)');
	}

	/**
	 * Gets the Array of Processes Running on the 3DS.
	 * 
	 * This also can be found by `L + D-Pad Down + Select` > `Process List`
	 * 
	 * @return An Array of Strings if it's successful, null if Failed.
	 */
	public static function getProcessNames():Null<Array<String>> {
		var out:Array<String> = [];

		untyped __cpp__('
			u32 processIDs[0x50] = { 0};
			s32 count = 0;
			if (R_FAILED(svcGetProcessList(&count, processIDs, 0x50))) {
				return null();
			}

			for (s32 i = 0; i < count; i++) {
				Handle process;
				if (R_FAILED(svcOpenProcess(&process, processIDs[i]))) {
					continue;
				}

				char procName[8] = { 0};
				if (R_FAILED(svcGetProcessInfo((s64*)procName, process, 0x10000))) {
					svcCloseHandle(process);
					continue;
				}

				out->push(String(procName));
				svcCloseHandle(process);
			}
		');

		return out;
	}
}