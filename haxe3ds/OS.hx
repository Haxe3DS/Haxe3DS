package haxe3ds;

import haxe3ds.Types.Result;
using StringTools;

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
	public static var version(get, null):{version:String, result:Result};
	static function get_version():{version:String, result:Result} {
		var out:String = "";
		var result:Result = 0;

		untyped __cpp__('
			char in[15];
			result = osGetSystemVersionDataString(NULL, NULL, in, 15);
			out = in
		');

		return {
			version: out,
			result: result
		}
	}

	/**
	 * Converts a formatted version string to integer, only useful for checking versions.
	 * @param version Version Parser to use, must be identically as this format: `%u.%u.%u-%u%c`.
	 * @return `-1` if string is shorter than 7 or longer than 12, `0 ~ 11` if string is not formatted to the format, else becomes a integer.
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
}