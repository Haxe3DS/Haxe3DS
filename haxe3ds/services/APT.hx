package haxe3ds.services;

import haxe3ds.Types.Result;

/**
 * The flags that can be used to launch for System Settings.
 * @see https://www.3dbrew.org/wiki/System_Settings#Launch_parameters
 * @since 1.6.0
 */
enum abstract APTSystemSettingsFlag(UInt8) {
	/**
	 * Normally jumps to the default place of System Settings, like launching System Settings in the HOME Menu.
	 */
	var NORMAL;

	/**
	 * A setup flag that internally calls if it's unboxing a new 3ds or formatting it and turning it on.
	 * 
	 * ### WARNING:
	 * - It will erase the console's whole Mii Maker Data, including your personal MII!!! Use it with caution.
	 */
	var SETUP;

	/**
	 * Shortcut to `Internet Settings` > `Other Information`, stuff like `"User Agreement"` and `"Confirm MAC address"`.
	 */
	var INTERNET_SETTINGS_OTHER_SETTINGS = 0x11;

	/**
	 * Shortcut to `Internet Settings`, this is where the user can configure their internet.
	 */
	var INTERNET_SETTINGS = 0x6E;

	/**
	 * Shortcut to `Parental Controls` like setting up or changing the settings on there.
	 */
	var PARENTAL_CONTROLS;

	/**
	 * Shortcut to `Parental Controls` but for the birthday entry.
	 */
	var PARENTAL_CONTROLS_BIRTHDAY_ENTRY;

	/**
	 * Shortcut to `Data Management`, to backup saves, delete softwares, and more.
	 */
	var DATA_MANAGEMENT;

	/**
	 * Shortcut to `Data Management` > `Nintendo 3DS` > `Softwares`, to delete software stuff.
	 */
	var SOFTWARE_MANAGEMENT_SOFTWARES;

	/**
	 * Shortcut to `Data Management` > `Nintendo 3DS` > `Extra Data`, to delete extra data you don't need.
	 */
	var SOFTWARE_MANAGEMENT_EXTRA_DATA;

	/**
	 * Shortcut to `Data Management` > `DSiWare`, to backup, delete, transfer DSi Softwares.
	 */
	var NINTENDO_DSI_SOFTWARES;

	/**
	 * Shortcut to `Data Management` > `StreetPass Data Management`.
	 */
	var STREETPASS_DATA_MANAGEMENT;

	/**
	 * Shortcut to `Other Settings` > `Page 4`, Relates to updating the system?
	 * 
	 * Notes:
	 * - Softlocks on Hardware 3DS?
	 * - System Settings will return to it's initial settings instead of the HOME Menu.
	 */
	var OTHER_SETTINGS_PAGE_4 = 0x77;

	/**
	 * Shortcut to `Other Settings` > `Page 1` > `Touch Screen`, to calibrate your touches.
	 */
	var OTHER_SETTINGS_TOUCH_CALIBRATION;

	/**
	 * Shortcut to `Other Settings` > `Page 4` > `Circle Pad`, to calibrate your circle pad.
	 */
	var OTHER_SETTINGS_CIRCLE_PAD;

	/**
	 * Shortcut to `Other Settings` > `Page 5` > `System Update`, with the prompt of asking you to connect to the internet.
	 * 
	 * This is also used for the "Safe Mode".
	 */
	var OTHER_SETTINGS_SYSTEM_UPDATE;
	
	/**
	 * Shortcut to `Other Settings` > `Page 5` > `Format System Memory`, with something that's risky.
	 * 
	 * Note: System Settings will return to it's initial settings instead of the HOME Menu.
	 */
	var OTHER_SETTINGS_FORMAT_SYSTEM = 124;
}

/**
 * The hook type on how it happend by the system.
 * @since 1.6.0
 */
enum abstract APTHookType(Int) {
	/**
	 * Suspend happens if user pressed the HOME Menu.
	 * 
	 * Value: `0`
	 */
	var SUSPEND;

	/**
	 * Resume happens while in the HOME Menu.
	 * 
	 * Value: `1`
	 */
	var RESUME;

	/**
	 * System is sleeping due to User's Request.
	 * 
	 * Value: `2`
	 */
	var SLEEP;

	/**
	 * System stops sleeping due to User's Request.
	 * 
	 * Value: `3`
	 */
	var WAKEUP;

	/**
	 * Exit happens if user exits this app, only works in CIA?
	 * 
	 * Value: `4`
	 */
	var EXIT;
}

/**
 * APT (Applet) service.
 * 
 * This is where the most popular functions (such as `mainLoop`) is located.
 */
@:cppFileCode('
#include <string.h>
#include "haxe3ds_services_GFX.h"

aptHookCookie cookie;
void hookTest(APT_HookType hook, void* param) {
	UNUSED_VAR(param);
	auto hooky = haxe3ds::services::APT::hookHandler;
	if (hooky != nullptr) {
		hooky(hook);
	}
}
')
class APT {
	/**
	 * Variable if the 3DS model is the NEW 3DS instead of OLD 3DS.
	 * 
	 * Automatically gets set when APT is initialized, so use that first.
	 * 
	 * *This variable is ***REQUIRED*** to Initialize APT*
	 */
	public static var isNew3DS(default, null):Bool = false;

	/**
	 * The current Program/Title ID running.
	 * 
	 * Homebrew Launcher's TID: `0x000400000D921E00 (1125900134522368)` (This is always different if using a CIA with a custom TID)
	 * 
	 * *This variable is ***REQUIRED*** to Initialize APT*
	 * 
	 * @since 1.4.0
	 */
	public static var programID(default, null):UInt64 = 0;

	/**
	 * Hook Handler Function for any System Events, can be if the system is sleeping, or just pure silly things.
	 * 
	 * *This variable is ***REQUIRED*** to Initialize APT*
	 * 
	 * @since 1.6.0
	 */
	public static var hookHandler:(APTHookType)->Void;

	/**
	 * This gets/sets the amount of syscore CPU time available to the running application. It can range from 5% to 89%. Maximum value depends on the ExHeader. Setting a value higher than 30% does not seem to improve performance on Old 3DS, however it definitely does on New 3DS. 
	 * 
	 * @since 1.5.0
	 */
	public static var cpuTimeLimit(get, set):UInt32;
	static function get_cpuTimeLimit():UInt32 {
		var out:UInt32 = 0;
		untyped __cpp__('APT_GetAppCpuTimeLimit(&out)');
		return out;
	}
	static function set_cpuTimeLimit(cpuTimeLimit:UInt32):UInt32 {
		return untyped __cpp__('APT_SetAppCpuTimeLimit(cpuTimeLimit)');
	}

	/**
	 * Initializes APT, well not really just sets up the other variables.
	 * 
	 * Which would be `isNew3DS` and `programID`
	 */
	public static function init() {
		untyped __cpp__('
			APT_CheckNew3DS(&isNew3DS);
			APT_GetProgramID(&programID);
			aptHook(&cookie, hookTest, nullptr)
		');
	}

	/**
	 * Exits APT.
	 */
	@:native("aptExit")
	public static function exit() {};

	/**
	 * Variable property for locking/unlocking HOME Menu.
	 * 
	 * If `homeMenu` is set to `true`, allows the console to access the HOME Menu, else will disallow accessing to HOME Menu.
	 * 
	 * `Get` will fetch `aptIsHomeAllowed()`
	 * 
	 * `Set` will call function `aptSetHomeAllowed()` with home param.
	 */
	public static var homeMenu(get, set):Bool;
	static function get_homeMenu():Bool return untyped __cpp__('aptIsHomeAllowed()');
	static function set_homeMenu(homeMenu:Bool):Bool {
		untyped __cpp__('aptSetHomeAllowed(homeMenu)');
		return homeMenu;
	}

	/**
	 * Jumps back to the HOME menu by making the console think you've pressed the HOME Button.
	 */
	@:native("aptJumpToHomeMenu")
	public static function jumpToHomeMenu() {};

	/**
	 * Returns true if there is an incoming HOME button press rejected by the policy set by `APT.homeMenu`
	 */
	@:native("aptCheckHomePressRejected")
	public static function isHomePressed():Bool return false;

	/**
	 * Main function which handles sleep mode and HOME/power buttons - call this at the beginning of every frame.
	 * 
	 * This internally calls `HID.scanInput()`, `gspWaitForVBlank()` and `gfxSwapBuffers()`.
	 * 
	 * @return true if the application should keep running, false otherwise.
	 */
	public static function mainLoop():Bool {
		HID.scanInput();
		return untyped __cpp__('(gspWaitForVBlank(), gfxSwapBuffers(), aptMainLoop())');
	}

	/**
	 * Returns true if the application is currently in the foreground.
	 */
	@:native("aptIsActive")
	public static function isActive():Bool return false;

	/**
	 * Variable property for the sleeping functionality.
	 * 
	 * If `canSleep` is true, 3DS can be allowed to sleep, else cannot sleep.
	 * 
	 * `Get` will fetch `aptIsSleepAllowed()`
	 * 
	 * `Set` will call function `aptSetSleepAllowed()` with sleep param.
	 */
	public static var canSleep(get, set):Bool;
	static function get_canSleep():Bool return untyped __cpp__('aptIsSleepAllowed()');
	static function set_canSleep(canSleep:Bool):Bool {
		untyped __cpp__('aptSetSleepAllowed(canSleep)');
		return canSleep;
	}

	/**
	 * Returns true if the system requires the application to jump back to the HOME menu.
	 */
	@:native("aptShouldJumpToHome")
	public static function shouldJumpToHome():Bool return false;

	/**
	 * Jumps to System Settings with region support and with flags!
	 * 
	 * Notes:
	 * - Call `CFGU.init` to enable support for regions, not doing it will launch the wrong Title ID and throw an exception!
	 * - This will QUIT the application running.
	 * - Sometimes softlocks the 3DS for apparently no reason, even if system settings isn't launched.
	 * - Emulators like AZAHAR has region set to `Auto-Select` instead of the proper region, and can cause a restart.
	 * - Booting to System Settings is slow and takes ~10 seconds to launch.
	 * 
	 * @param flag Flag to use for System Settings.
	 * @return Result to indicate if something went wrong or not.
	 * @see APTSystemSettingsFlag enum
	 * @since 1.6.0
	 */
	public static function jumpToSystemSettingsWithFlag(flag:APTSystemSettingsFlag = NORMAL):Result {
		final lowTID:UInt32 = switch (CFGU.region) {
			case "JPN": 0x00020000;
			case "USA" | "AUS": 0x00021000;
			case "EUR": 0x00022000;
			case "CHN": 0x00026000;
			case "KOR": 0x00027000;
			case "TWN": 0x00028000;
			default: 0x00021000;
		};

		var ret:Result = 0;
		untyped __cpp__('
			u8 paramBuffer[0x300] = {0};
			u8 workBuffer[0x20] = {0};
			u32 sceneParam = (u32)flag;
			memcpy(paramBuffer, &sceneParam, 4U);

			if (R_FAILED(ret = APT_PrepareToDoApplicationJump(0, 0x00040010ULL << 32 | lowTID, MEDIATYPE_NAND))) goto fail;
			if (R_FAILED(ret = APT_DoApplicationJump(paramBuffer, 4, workBuffer))) goto fail;

			fail:
		');
		return ret;
	}
}