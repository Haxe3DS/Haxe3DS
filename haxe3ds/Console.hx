package haxe3ds;

/**
 * Screen Graphical Enum
 */
enum abstract GFXScreen(Int) {
	/**
	 * The 3DS's top screen. Resolution at 400x240.
	 */
	var	TOP;

	/**
	 * The 3DS's bottom screen. Resolution at 320x240.
	 */
	var BOTTOM;
}

/**
 * Graphical ANSI Color.
 */
enum abstract ConsoleColor(String) {
	var textBlack = "\x1b[30;1m";
	var textRed = "\x1b[31;1m";
	var textGreen = "\x1b[32;1m";
	var textYellow = "\x1b[33;1m";
	var textBlue = "\x1b[34;1m";
	var textMagenta = "\x1b[35;1m";
	var textCyan = "\x1b[36;1m";
	var textWhite = "\x1b[37;1m";

	var borderBlack = "\x1b[40;1m";
	var borderRed = "\x1b[41;1m";
	var borderGreen = "\x1b[42;1m";
	var borderYellow = "\x1b[43;1m";
	var borderBlue = "\x1b[44;1m";
	var borderMagenta = "\x1b[45;1m";
	var borderCyan = "\x1b[46;1m";
	var borderWhite = "\x1b[47;1m";
}

/**
 * Console's Private Use Area
 * 
 * @see https://unicode-explorer.com/b/E000
 */
enum abstract ConsolePUA(String) {
	var buttonA = "\uE000";
	var buttonB = "\uE001";
	var buttonY = "\uE002";
	var buttonX = "\uE003";
	var buttonL = "\uE004";
	var buttonR = "\uE005";
	var dpad = "\uE006";
	var target = "\uE01D";
	var camera = "\uE01E";
	var dpadAny = "\uE041";
	var questionBlock = "\uE06B";
	var close = "\uE070";
	var closeHighlight = "\uE071";
	var back = "\uE072";
	var home = "\uE073";
	var steps = "\uE074";
	var playCoin = "\uE075";
	var film = "\uE076";
	var circlePad = "\uE077";
	var power = "\uE078";
	var dpadUp = "\uE079";
	var dpadDown = "\uE07A";
	var dpadLeft = "\uE07B";
	var dpadRight = "\uE07C";
	var dpadVert = "\uE07D";
	var dpadHori = "\uE07E";
}

/**
 * 3ds STDIO support.
 *
 * Provides STDIO integration for printing to the 3DS screen as well as debug print functionality provided by STDERR.
 */
@:cppInclude("haxe3ds_Utils.h")
class Console {
	/**
	 * Initialise the console, enabling tracing or printing to the console.
	 * @param screen The GFX Screen to use to initialize.
	 */
	public static function init(screen:GFXScreen = TOP) untyped __cpp__('consoleInit((gfxScreen_t)screen, NULL)');

	/**
	 * Clears the Console Screen by using the Built-In Function `printf("\x1b[2J")`
	 */
	public static function clear() untyped __cpp__('printf("\\x1b[2J")');
}