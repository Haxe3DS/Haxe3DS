package haxe3ds;

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
	public static var textBlack:String = "\x1b[30;1m";
	public static var textRed:String = "\x1b[31;1m";
	public static var textGreen:String = "\x1b[32;1m";
	public static var textYellow:String = "\x1b[33;1m";
	public static var textBlue:String = "\x1b[34;1m";
	public static var textMagenta:String = "\x1b[35;1m";
	public static var textCyan:String = "\x1b[36;1m";
	public static var textWhite:String = "\x1b[37;1m";

	public static var borderBlack:String = "\x1b[40;1m";
	public static var borderRed:String = "\x1b[41;1m";
	public static var borderGreen:String = "\x1b[42;1m";
	public static var borderYellow:String = "\x1b[43;1m";
	public static var borderBlue:String = "\x1b[44;1m";
	public static var borderMagenta:String = "\x1b[45;1m";
	public static var borderCyan:String = "\x1b[46;1m";
	public static var borderWhite:String = "\x1b[47;1m";
}

/**
 * 3ds STDIO support.
 *
 * Provides STDIO integration for printing to the 3DS screen as well as debug print
 * functionality provided by STDERR.
 *
 * General usage is to initialize the console by:
 * ```
 * import hx3ds.Console;
 * consoleDemoInit(); // DOES NOT EXIST YET
 * ```
 * or to customize the console usage by:
 * ```
 * import hx3ds.Console;
 * Console.init();
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