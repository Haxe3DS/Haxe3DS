package haxe3ds;

using StringTools;

/**
 * @see https://www.3dbrew.org/wiki/Configuration_Memory#UNITINFO
 * @since 1.5.0
 */
enum OSBootEnv {
	PRODUCTION;

	/**
	 * This also happens if you are using an emulator (Azahar.)
	 */
	DEVELOPER;
	DEBUGGER;
	FIRMWARE;
	UNKNOWN;
}

/**
 * @see https://www.3dbrew.org/wiki/Configuration_Memory#RUNNING_HW
 * @since 1.5.0
 */
enum OSRunningHW {
	/**
	 * Indicates that the hardware type is unknown.
	 */
	INVALID;

	/**
	 * Indicates that the hardware is equivalent to the retail product.
	 */
	PRODUCT;

	/**
	 * Indicates the TS board.
	 */
	TS_BOARD;

	/**
	 * Indicates the PARTNER-CTR Debugger.
	 */
	KMC_DEBUGGER;

	/**
	 * Indicates the PARTNER-CTR Capture.
	 */
	KMC_CAPTURE;

	/**
	 * Indicates the Intelligent System CTR DEBUGGER.
	 */
	IS_DEBUGGER;

	/**
	 * Indicates the hardware equivalent to the SNAKE retail version.
	 */
	SNAKE_PRODUCT;

	/**
	 * Indicates Intelligent System SNAKE-BOX.
	 */
	SNAKE_IS_DEBUGGER;

	/**
	 * Indicates the version without the IS-SNAKE-BOX debugging feature.
	 */
	SNAKE_IS_CAPTURE;

	/**
	 * Indicates PARTNER-SNAKE Debugger.
	 */
	SNAKE_KMC_DEBUGGER;
}

/**
 * The network state displayed by Home Menu.
 * @see https://www.3dbrew.org/wiki/Configuration_Memory#Shared_Memory_Page_For_ARM11_Processes
 * @since 1.5.0
 */
enum OSNetwork {
	/**
	 * Console is connected to the internet.
	 * 
	 * This happens if the value is `2`.
	 */
	INTERNET;

	/**
	 * Console is connected in local mode, example being if it's in `Friend List` and pressed `Register Friend` > `Local`. Or launched `Download Play` and chose `Nintendo 3DS`.
	 *
	 * This happens if the value is `3`, `4` or `6`.
	 */
	LOCAL;

	/**
	 * Console is not connected to the instead, and instead displays if wireless communication is disabled.
	 *
	 * This happens if value is `7`.
	 */
	DISABLED;

	/**
	 * Console is not connected to the instead, and instead displays if wireless communication is enabled.
	 * 
	 * This happens if value is anything else other than the values above.
	 */
	ENABLED;
}

/**
 * Configuration for this 3DS.
 * 
 * @since 1.5.0
 */
typedef OSConfig = {
	/**
	 * (Config) The name that was booted up, by type.
	 */
	var bootEnvironment:OSBootEnv;

	/**
	 * (Shared) The current running hardware by type for this system.
	 */
	var runningHardware:OSRunningHW;

	/**
	 * (Shared) The current state of the 3DS's network.
	 */
	var networkState:OSNetwork;
}

/**
 * OS related stuff.
 */
@:cppInclude("haxe3ds_services_GFX.h")
class OS {
	/**
	 * Variable property that returns the number of milliseconds since 1st Jan 1900 00:00.
	 * 
	 * `Get` will call `osGetTime` as it's return.
	 */
	public static var time(get, null):UInt64;
	static function get_time():UInt64 {
		return untyped __cpp__('osGetTime()');
	}

	/**
	 * Variable property that gets the current Wifi signal strength.
	 *
	 * Valid values are 0-3:
	 * - 0 means the signal strength is terrible or the 3DS is disconnected from all networks.
	 * - 1 means the signal strength is bad.
	 * - 2 means the signal strength is decent.
	 * - 3 means the signal strength is good.
	 *
	 * Values outside the range of 0-3 should never be returned.
	 *
	 * These values correspond with the number of wifi bars displayed by Home Menu.
	 * 
	 * `Get` will call `osGetWifiStrength` as it's return.
	 */
	public static var wifiStrength(get, null):UInt8;
	static function get_wifiStrength():UInt8 {
		return untyped __cpp__('osGetWifiStrength()');
	}

	/**
	 * Variable property that gets the state of the 3D slider. (0.0 - 1.0)
	 * 
	 * `Get` will call `osGet3DSliderState` as it's return.
	 */
	public static var sliderState3D(get, null):Float;
	static function get_sliderState3D():Float {
		return untyped __cpp__('osGet3DSliderState()');
	}

	/**
	 * Variable property that checks whether a headset is connected.
	 * 
	 * `Get` will call `osIsHeadsetConnected` as it's return.
	 */
	public static var isHeadsetConnected(get, null):Bool;
	static function get_isHeadsetConnected():Bool {
		return untyped __cpp__('osIsHeadsetConnected()');
	}

	/**
	 * Variable property that configures the New 3DS speedup.
	 * 
	 * `Set` will both configure `osSetSpeedupEnable` and set the variable.
	 */
	@:isVar public static var speedup(null, set):Bool;
	static function set_speedup(speedup:Bool):Bool {
		untyped __cpp__('osSetSpeedupEnable(speedup)');
		return speedup;
	}

	/**
	 * Variable that returns the system's version by this format: `%u.%u.%u-%u%c`.
	 * 
	 * Will return garbage bytes if using an emulator.
	 * 
	 * @since 1.4.0
	 */
	public static var version(get, null):String;
	static function get_version():String {
		var out:String = "";

		untyped __cpp__('
			char in[15];
			osGetSystemVersionDataString(NULL, NULL, in, 15);
			out = in
		');

		return out;
	}

	/**
	 * Converts a formatted version string to integer, only useful for checking versions.
	 * @param version Version Parser to use, must be identically as this format: `%u.%u.%u-%u%c`.
	 * @return `-1` if string is shorter than 7 or longer than 12, `0 ~ 11` if string is not formatted to the format, else becomes a integer.
	 * @since 1.4.0
	 */
	public static function versionToInt(version:String):Int {
		function replWholeLetters(str:String, from:String, to:String):String {
			for (lol in from.split("")) str = str.replace(lol, to);
			return str;
		}

		function isNumber(i:String):Bool {
			return Std.parseInt(i) != null;
		}

		var l:Int = version.length;
		if (7 < l && l < 12) {
			for (k => i in version.split("")) {
				if (!(isNumber(i) || i == "." || i == "-") != (k+1 == l && !isNumber(i))) {
					return k;
				}
			}

			return Std.parseInt(replWholeLetters(version.substr(0, version.length-1), '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~', ""));
		}
		return -1;
	}

	/**
	 * Gets some of the kernel configs stored in the 3DS Systems.
	 * @return The Struct for OSConfig.
	 * @since 1.5.0
	 */
	public static function getKernelConfig():OSConfig {
		return {
			bootEnvironment: switch (untyped __cpp__('OS_KernelConfig->env_info')) {
				case 0: PRODUCTION;
				case 1: DEVELOPER;
				case 2: DEBUGGER;
				case 3: FIRMWARE;
				default: UNKNOWN;
			},

			runningHardware: switch(untyped __cpp__('OS_SharedConfig->running_hw')) {
				case 0: INVALID;
				case 1: PRODUCT;
				case 2: TS_BOARD;
				case 3: KMC_DEBUGGER;
				case 4: KMC_CAPTURE;
				case 5: IS_DEBUGGER;
				case 6: SNAKE_PRODUCT;
				case 7: SNAKE_IS_DEBUGGER;
				case 8: SNAKE_IS_CAPTURE;
				case 9: SNAKE_KMC_DEBUGGER;
				default: INVALID;
			},

			networkState: switch(untyped __cpp__('OS_SharedConfig->running_hw')) {
				case 2: INTERNET;
				case 3 | 4 | 6: LOCAL;
				case 7: DISABLED;
				default: ENABLED;
			}
		};
	}
}