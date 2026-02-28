package haxe3ds.services;

import haxe3ds.Types.Result;
import cpp.UInt8;

/**
 * MCU service.
 * 
 * @since 1.4.0
 */
@:cppInclude("haxe3ds_Utils.h")
class MCUWUC {
	/**
	 * Initializes MCUHWC for other variables to work.
	 */
	public static function init():Result {
		return untyped __cpp__('mcuHwcInit()');
	}

	/**
	 * Exits MCUHWC.
	 */
	@:native("mcuHwcExit")
	public static function exit() {}

	/**
	 * @see https://www.3dbrew.org/wiki/MCUHWC:GetBatteryVoltage
	 */
	public static var batteryVoltage(get, null):UInt8 = 0;
	static function get_batteryVoltage():UInt8 {
		return untyped __cpp__('API_GETTER(u8, MCUHWC_GetBatteryVoltage, 0)');
	}

	/**
	 * The current percentage on your 3DS `0 - 100 (0x64)`
	 */
	public static var batteryPercentage(get, null):UInt8;
	static function get_batteryPercentage():UInt8 {
		return untyped __cpp__('API_GETTER(u8, MCUHWC_GetBatteryLevel, 0)');
	}

	/**
	 * Variable if you wanna set the wifi led state to on or off.
	 */
	public static var wifiLEDState(null, set):Bool;
	static function set_wifiLEDState(wifiLEDState:Bool):Bool {
		untyped __cpp__('MCUHWC_SetWifiLedState(wifiLEDState)');
		return wifiLEDState;
	}

	/**
	 * The current MCU Firmware Version by this format: `%u-%u`.
	 * 
	 * Note:
	 * - It starts with `HI-LO`.
	 */
	public static var mcuVersion(get, null):Null<String>;
	static function get_mcuVersion():Null<String> {
		untyped __cpp__('
			u8 a, b;
			MCUHWC_GetFwVerHigh(&a);
			MCUHWC_GetFwVerLow(&b);

			char out[8];
			std::snprintf(out, 8, "%u-%u", a, b);
		');
		return untyped __cpp__('String(out)');
	}

	/**
	 * The current temperature for the 3DS, this can also be found in Luma3DS by holding down `L + DPAD DOWN + SELECT` and seeing the bottom screen.
	 * @since 1.6.0
	 */
	public static var temperature(get, null):Null<UInt8>;
	static function get_temperature():Null<UInt8> {
		untyped __cpp__('
			Result ret = 0;
			u32 *cmdbuf = getThreadCommandBuffer();

			cmdbuf[0] = IPC_MakeHeader(0xE,2,0);
			RETURN_NULL_IF_FAILED(ret = svcSendSyncRequest(*mcuHwcGetSessionHandle()));
		');

		return untyped __cpp__('cmdbuf[2]');
	}
}