package haxe3ds.services;

/**
 * APT (Applet) service.
 * 
 * This is where the most popular functions (such as `mainLoop`) is located.
 */
@:cppInclude("haxe3ds_services_GFX.h")
class APT {
	/**
	 * Variable if the 3DS model is the NEW 3DS instead of OLD 3DS.
	 * 
	 * Automatically gets set when APT is initialized, so use that first.
	 */
	public static var isNew3DS(default, null):Bool = false;

	/**
	 * The current Program/Title ID running.
	 * 
	 * Homebrew Launcher's TID: `0x000400000D921E00 (1125900134522368)` (This is always different if using a CIA with a custom TID)
	 * 
	 * @since 1.4.0
	 */
	public static var programID(default, null):UInt64 = 0;

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
			APT_GetProgramID(&programID)
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
	 * This internally calls `HID.scanInput()`
	 * 
	 * @return true if the application should keep running, false otherwise.
	 */
	public static function mainLoop():Bool {
		HID.scanInput();
		return untyped __cpp__('aptMainLoop()');
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
}