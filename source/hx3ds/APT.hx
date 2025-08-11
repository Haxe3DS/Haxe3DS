package hx3ds;

/**
 * APT (Applet) service.
 */
@:cppInclude("3ds.h")
class APT {
	/**
	 * Initializes APT.
	 */
	@:native("aptInit")
	public static function init():Void {};

	/**
	 * Exits APT.
	 */
	@:native("aptExit")
	public static function exit():Void {};

	/**
	 * Checks whether the system is a New 3DS.
	 * @return `true` if you're using a New 3DS, `false` otherwise.
	 */
	public static function isNew3DS():Bool {
		var check:Bool = false;
		untyped __cpp__("APT_CheckNew3DS(&check);");
		return check;
	}

	/**
	 * Returns true if the user can press the HOME button to jump back to the HOME menu while the application is active.
	 */
	@:native("aptIsHomeAllowed")
	public static function isHomeAllowed():Bool return false;

	/**
	 * Configures whether the user can press the HOME button to jump back to the HOME menu while the application is active.
	 * @param allowed Should allow going to home menu?
	 */
	@:native("aptSetHomeAllowed")
	public static function setHomeAllowed(allowed:Bool):Void {};

	/**
	 * Jumps back to the HOME menu by making the console think you've pressed the HOME Button.
	 */
	@:native("aptJumpToHomeMenu")
	public static function jumpToHomeMenu():Void {};

	/**
	 * Returns true if there is an incoming HOME button press rejected by the policy set by APT.setHomeAllowed
	 */
	@:native("aptCheckHomePressRejected")
	public static function isHomePressed():Bool return false;

	/**
	 * Main function which handles sleep mode and HOME/power buttons - call this at the beginning of every frame.
	 * @return true if the application should keep running, false otherwise.
	 */
	@:native("aptMainLoop")
	public static function mainLoop():Bool return false;
}
