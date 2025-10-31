package haxe3ds.services;

import haxe3ds.Types.Result;
import cxx.num.UInt8;
import cxx.num.UInt32;

enum GSPLCDScreen {
	/**
	 * Top screen.
	 */
	TOP;

	/**
	 * Bottom screen.
	 */
	BOTTOM;

	/**
	 * Both screens.
	 */
	BOTH;
}

/**
 * GSPLCD service.
 * 
 * @since 1.2.0
 */
@:cppFileCode('
#include "haxe3ds_services_GFX.h"

u32 screenToU32(std::shared_ptr<haxe3ds::services::GSPLCDScreen> i) {
	switch(i->index) {
		case 0: return GSPLCD_SCREEN_TOP;
		case 1: return GSPLCD_SCREEN_BOTTOM;
		case 2: return GSPLCD_SCREEN_BOTH;
	}
}')
class GSPLCD {
	/**
	 * Variable Property that forcefully sets the LED, and won't forcefully get the property.
	 * 
	 * This calls `GSPLCD_SetLedForceOff` if you set the variable.
	 */
	public static var LED(null, set):Bool;
	static function set_LED(LED:Bool):Bool {
		untyped __cpp__('GSPLCD_SetLedForceOff(!LED)');
		return LED;
	}

	/**
	 * Variable that Gets the LCD screens' vendors. Stubbed on OLD 3ds.
	 */
	public static var vendors(default, null):UInt8 = 0;

	/**
	 * Initializes GSPLCD.
	 */
	public static function init() {
		untyped __cpp__('
			gspLcdInit();
			GSPLCD_GetVendors(&vendors);
		');
	}

	/**
	 * Sets the backlight from the 3DS
	 * @param screen Screen to use.
	 * @param enable Whetever or not you want to enable it.
	 */
	public static function setBacklight(screen:GSPLCDScreen, enable:Bool):Result {
		var res:Result = 0;
		
		untyped __cpp__('
			u32 s = screenToU32(screen);
			res = (enable ? GSPLCD_PowerOnBacklight(s) : GSPLCD_PowerOffBacklight(s))
		');

		return res;
	}

	/**
	 * Gets the Screen Brightness from screen provided.
	 * @param screen Screen to use, top or bottom only.
	 * @return Brightness from screen. (`0x10 (16)` - `0xAC (172)`)
	 */
	public static function getScreenBrightness(screen:GSPLCDScreen):UInt8 {
		var r:UInt32 = 0;
		untyped __cpp__('GSPLCD_GetBrightness(screenToU32(screen), &r)');
		return r;
	}

	/**
	 * Sets the Screen Brightness from screen provided.
	 * 
	 * @param screen Screen to use, top or bottom only.
	 * @param brightness Brightness variable to set as. (`0x10 (16)` - `0xAC (172)`), will clamp into compatible values.
	 */
	public static function setScreenBrightness(screen:GSPLCDScreen, brightness:UInt8):Result {
		var res:Result = 0;

		untyped __cpp__('res = GSPLCD_SetBrightnessRaw(screenToU32(screen), (u32)(brightness < 16 ? 16 : brightness > 172 ? 172 : brightness))');

		return res;
	}

	/**
	 * Exits GSPLCD.
	 */
	@:native("gspLcdExit")
	public static function exit() {}
}