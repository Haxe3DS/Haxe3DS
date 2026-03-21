package haxe3ds.services;

import haxe3ds.types.Result;
import cpp.UInt8;
import cpp.UInt32;

enum abstract GSPLCDScreen(Int) {
	/**
	 * Top screen.
	 */
	var TOP = 1;

	/**
	 * Bottom screen.
	 */
	var BOTTOM;

	/**
	 * Both screens.
	 */
	var BOTH;
}

/**
 * GSPLCD service.
 * 
 * @since 1.2.0
 */
@:cppInclude("haxe3ds_Utils.h")
class GSPLCD {
	/**
	 * Variable Property that forcefully sets the LED, and won't forcefully get the property.
	 * 
	 * This calls `GSPLCD_SetLedForceOff` if you set the variable.
	 */
	public static var LED(null, set):Bool;
	static function set_LED(LED):Bool {
		untyped __cpp__('GSPLCD_SetLedForceOff(!LED)');
		return LED;
	}

	/**
	 * Variable that Gets the LCD screens' vendors. Stubbed on OLD 3ds.
	 */
	public static var vendors(get, null):UInt8;
	static function get_vendors():UInt8 {
		return untyped __cpp__('API_GETTER(u8, GSPLCD_GetVendors, 0)');
	}

	/**
	 * Initializes GSPLCD.
	 */
	public static inline function init() {
		untyped __cpp__('gspLcdInit()');
	}

	/**
	 * Sets the backlight from the 3DS
	 * @param screen Screen to use.
	 * @param enable Whether or not you want to enable it.
	 */
	public static function setBacklight(screen:GSPLCDScreen, enable:Bool):Result {
		return untyped __cpp__('enable ? GSPLCD_PowerOnBacklight(screen) : GSPLCD_PowerOffBacklight(screen)');
	}

	/**
	 * Gets the Screen Brightness from screen provided.
	 * @param screen Screen to use, top or bottom only.
	 * @return Brightness from screen. (`0x10 (16)` - `0xAC (172)`)
	 */
	public static function getScreenBrightness(screen:GSPLCDScreen):UInt8 {
		var r:UInt32 = 0;
		untyped __cpp__('GSPLCD_GetBrightness(screen, &r)');
		return r;
	}

	/**
	 * Sets the Screen Brightness from screen provided.
	 * @param screen Screen to use, top or bottom only.
	 * @param brightness Brightness variable to set as. (`0x10 (16)` - `0xAC (172)`), will clamp into compatible values.
	 */
	public static function setScreenBrightness(screen:GSPLCDScreen, brightness:UInt8):Result {
		var res:Result = 0;
		untyped __cpp__('res = GSPLCD_SetBrightnessRaw(screen, (u32)(brightness < 16 ? 16 : brightness > 172 ? 172 : brightness))');
		return res;
	}

	/**
	 * Exits GSPLCD.
	 */
	public static inline function exit() {
		untyped __cpp__('gspLcdExit()');
	}
}