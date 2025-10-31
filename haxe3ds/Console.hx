package haxe3ds;

/**
 * Screen Graphical Enum
 */
enum GfxScreen_t {
	/**
	 * The 3DS's top screen. Resolution at 400x240.
	 */
	@:native("GFX_TOP")	GFX_TOP;

	/**
	 * The 3DS's bottom screen. Resolution at 320x240.
	 */
	@:native("GFX_BOTTOM") GFX_BOTTOM;
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
 * Console's Private Use Area
 * 
 * @see https://unicode-explorer.com/b/E000
 */
class ConsolePUA {
	public static var buttonA:String   = "\uE000";
	public static var buttonB:String   = "\uE001";
	public static var buttonY:String   = "\uE002";
	public static var buttonX:String   = "\uE003";
	public static var buttonL:String   = "\uE004";
	public static var buttonR:String   = "\uE005";
	public static var dpad:String	  = "\uE006";
	public static var target:String	= "\uE01D";
	public static var camera:String	= "\uE01E";
	public static var dpadAny:String   = "\uE041";
	public static var back:String	  = "\uE072";
	public static var home:String	  = "\uE073";
	public static var steps:String	 = "\uE074";
	public static var playCoin:String  = "\uE075";
	public static var film:String	  = "\uE076";
	public static var circlePad:String = "\uE077";
	public static var power:String	 = "\uE078";
	public static var dpadUp:String	= "\uE079";
	public static var dpadDown:String  = "\uE07A";
	public static var dpadLeft:String  = "\uE07B";
	public static var dpadRight:String = "\uE07C";
	public static var dpadVert:String  = "\uE07D";
	public static var dpadHori:String  = "\uE07E";
	public static var close:String	 = "\uE070";
	public static var closeHighlight:String = "\uE071";
	public static var questionBlock:String  = "\uE06B";
}

/**
 * 3ds STDIO support.
 *
 * Provides STDIO integration for printing to the 3DS screen as well as debug print
 * functionality provided by STDERR.
 */
class Console {
	/**
	 * Initialise the console.
	 * @param screen The screen to use for the console.
	 */
	@:native("consoleInit")
	public static function init(screen:GfxScreen_t, _:String = null) {};

	/**
	 * Clears the screen by using iprintf("\x1b[2J");
	 */
	@:native("consoleClear")
	public static function clear() {};
}