package haxe3ds;

import cpp.UInt8;
import cpp.UInt16;
import cpp.UInt64;
import haxe3ds.Types.NanoTime;
import haxe3ds.Types.Result;

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
 * The Concurrent Emulator that is currently using.
 */
enum abstract SVCEmulatorID(UInt8) {
	/**
	 * Application is being emulated by Citra.
	 */
	var CITRA = 1;

	/**
	 * Application is being emulated by Azahar.
	 */
	var AZAHAR;
}

/**
 * The current Platform that's currently emulating.
 * 
 * @since 1.8.0
 */
enum abstract SVCEmulatorPlatform(UInt8) {
	/**
	 * Unknown Platform.
	 */
	var UNKNOWN;

	/**
	 * Emulation is running on Windows.
	 */
	var WINDOWS;

	/**
	 * Emulation is running on Linux.
	 */
	var LINUX;

	/**
	 * Emulation is running on Apple.
	 */
	var APPLE;

	/**
	 * Emulation is running on Android.
	 */
	var ANDROID;
}

/**
 * A typedef for the Current Emulator Info.
 * 
 * @since 1.8.0
 */
typedef SVCEmulatorInfo = {
	/**
	 * Current Emulator ID, Can be 1 or 2.
	 *
	 * @see https://github.com/azahar-emu/azahar/blob/37e688f82d42917a8d232b8e9b49ecee814846b4/src/core/hle/kernel/svc.cpp#L309
	 */
	var emulatorID:SVCEmulatorID;

	/**
	 * `Tick reference from the host in ns, unaffected by lag or cpu speed.`
	 */
	var hostTick:NanoTime;

	/**
	 * The current Emulation Speed (Seen by `Speed: XXX% / XXX%`)
	 */
	var emulationSpeed:UInt16;

	/**
	 * The emulator that is running on.
	 * 
	 * @see https://github.com/azahar-emu/azahar/blob/37e688f82d42917a8d232b8e9b49ecee814846b4/src/core/hle/kernel/svc.cpp#L318
	 */
	var platform:SVCEmulatorPlatform;
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

	public static var emulator(get, null):Null<SVCEmulatorInfo>;
	static function get_emulator():Null<SVCEmulatorInfo> {
		untyped __cpp__('
			#define SVC_PROPERTY(index) \\
				([&]{ \\
					s64 OUT; \\
					svcGetSystemInfo(&OUT, 0x20000, (s32)index); \\
					return OUT; \\
				})()

			s8 eID = SVC_PROPERTY(0);
			if (eID == 0) {
				return null();
			}
		');

		return {
			emulatorID: untyped __cpp__('eID'),
			hostTick: untyped __cpp__('SVC_PROPERTY(1)'),
			emulationSpeed: untyped __cpp__('SVC_PROPERTY(2)'),
			platform: untyped __cpp__('SVC_PROPERTY(12)')
		}
	}
}