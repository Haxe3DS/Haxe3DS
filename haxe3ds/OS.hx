package haxe3ds;

/**
 * OS related stuff.
 */
@:cppInclude("3ds.h")
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
	 * `Get` will return the current variable set.
	 * 
	 * `Set` will both configure `osSetSpeedupEnable` and set the variable.
	 */
	@:isVar public static var speedup(get, set):Bool;
	static function get_speedup():Bool {
		return speedup;
	}
	static function set_speedup(speedup:Bool):Bool {
		untyped __cpp__('osSetSpeedupEnable(speedup)');
		return speedup;
	}
}