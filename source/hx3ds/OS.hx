package hx3ds;

/**
 * OS related stuff.
 */
@:cppInclude("3ds.h")
class OS {
	/**
	 * Gets the current time.
	 * @return The number of milliseconds since 1st Jan 1900 00:00.
	 */
	@:native("osGetTime")
	public static function getTime():UInt64 return 0;

	/**
	 * Gets the current Wifi signal strength.
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
	 * @return The current Wifi signal strength.
	 */
	@:native("osGetWifiStrength")
	public static function getWifiStrength():UInt8 return 0;

	/**
	 * Gets the state of the 3D slider.
	 * @return The state of the 3D slider (0.0~1.0)
	 */
	@:native("osGet3DSliderState")
	public static function get3DSliderState():Float return 0;

	/**
	 * Gets the state of the 3D slider.
	 * @return The state of the 3D slider (0.0~1.0)
	 */
	@:native("osIsHeadsetConnected")
	public static function isHeadsetConnected():Bool return false;

	/**
	 * Configures the New 3DS speedup.
	 * @param enable Specifies whether to enable or disable the speedup.
	 */
	@:native("osSetSpeedupEnable")
	public static function setSpeedupEnable(enable:Bool) {};
}