package haxe3ds.services;

/**
 * APT (Applet) service.
 * 
 * This is where the most popular functions (such as `mainLoop`) is located.
 */
@:cppInclude("3ds.h")
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
	 */
	public static var programID(default, null):UInt64 = 0;

	/**
	 * Initializes APT.
	 */
	public static function init() {
		untyped __cpp__('
			aptInit();
			APT_CheckNew3DS(&isNew3DS);
			APT_GetProgramID(&programID);
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
	 * @return true if the application should keep running, false otherwise.
	 */
	@:native("aptMainLoop")
	public static function mainLoop():Bool return false;

	/**
	 * Returns true if the application is currently in the foreground.
	 */
	@:native("aptIsActive")
	public static function isActive():Bool return false;

	/**
	 * Returns true if the system has told the application to close.
	 */
	@:native("aptShouldClose")
	public static function shouldClose():Bool return false;

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
	 * Handles incoming sleep mode requests.
	 */
	@:native("aptHandleSleep")
	public static function handleSleep() {};

	/**
	 * Returns true if the system requires the application to jump back to the HOME menu.
	 */
	@:native("aptShouldJumpToHome")
	public static function shouldJumpToHome():Bool return false;

	/**
	 * Handles incoming jump-to-HOME requests.
	 */
	@:native("aptHandleJumpToHome")
	public static function handleJumpToHome() {};
}
