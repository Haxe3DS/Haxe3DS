package hx3ds;

/**
 * Screen Graphical Enum
 */
enum GfxScreen_t {
	/**
	 * The 3DS's top screen. Resolution at 400x240.
	 */
	@:native("GFX_TOP")
	GFX_TOP;

	/**
	 * The 3DS's bottom screen. Resolution at 320x240.
	 */
	@:native("GFX_BOTTOM")
	GFX_BOTTOM;
}

/**
 * Graphical ANSI Color.
 */
class ConsoleColor {
	public static var red:String = "\x1b[31;1m";
	public static var green:String = "\x1b[32;1m";
	public static var yellow:String = "\x1b[33;1m";
	public static var blue:String = "\x1b[34;1m";
	public static var magenta:String = "\x1b[35;1m";
	public static var cyan:String = "\x1b[36;1m";
	public static var white:String = "\x1b[37;1m";
}

/**
 * 3ds STDIO support.
 *
 * Provides STDIO integration for printing to the 3DS screen as well as debug print
 * functionality provided by STDERR.
 *
 * General usage is to initialize the console by:
 * ```
 * consoleDemoInit()
 * ```
 * or to customize the console usage by:
 * ```
 * consoleInit()
 * ```
 */
class Console {
	/**
	 * Initialise the console.
	 * @param screen The screen to use for the console.
	 */
	@:native("consoleInit")
	public static function init(screen:GfxScreen_t, _:String = null):Void {};

	/**
	 * Clears the screen by using iprintf("\x1b[2J");
	 */
	@:native("consoleClear")
	public static function clear():Void {};
}