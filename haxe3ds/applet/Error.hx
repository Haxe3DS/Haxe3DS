package haxe3ds.applet;

import cpp.UInt32;
import cpp.UInt16;
import haxe3ds.services.CFG.CFGLanguage;

/**
 * The type of applet to call.
 */
enum abstract ErrorType(Int) {
	/**
	 * Displays the infrastructure communications-related error message corresponding to the error code.
	 * 
	 * Also known as `Network Error`.
	 */
	var CODE;

	/**
	 * Displays text passed to this applet.
	 */
	var TEXT;

	/**
	 * Displays the EULA.
	 */
	var EULA;

	/**
	 * Displays a network error message in a specified language.
	 */
	var CODE_LANGUAGE = 256;

	/**
	 * Displays text passed to this applet in a specified language.
	 */
	var TEXT_LANGUAGE;

	/**
	 * Displays EULA in a specified language.
	 */
	var EULA_LANGUAGE;

	/**
	 * Displays the custom error message passed to this applet with automatic line wrapping.
	 */
	var TEXT_WORD_WRAP = 513;

	/**
	 * Displays the custom error message with automatic line wrapping and in the specified language.
	 */
	var TEXT_LANGUAGE_WORD_WRAP = 769;
}

/**
 * Return code. Stores the return code that indicates the reason why the Error/EULA applet terminated.
 * 
 * @since 1.3.0
 */
enum ErrorReturnCode {
	/**
	 * Abnormal end. No special action needs to be taken.
	 */
	UNKNOWN;

	/**
	 * Normal termination or EULA non-agreement.
	 */
	NONE;

	/**
	 * Application jump recommended termination or EULA agreement.
	 */
	SUCCESS;

	/**
	 * Outside the EULA service area.
	 */
	NOT_SUPPORTED;

	/**
	 * HOME was pressed.
	 */
	HOME_BUTTON;

	/**
	 * A button combination was pressed that causes a software reset.
	 */
	SOFTWARE_RESET;

	/**
	 * The POWER Button was pressed.
	 */
	POWER_BUTTON;
}

/**
 * Result provided from `Error.display`.
 * 
 * @since 1.3.0
 */
typedef ErrorResult = {
	/**
	 * Return code. Stores the return code that indicates the reason why the Error/EULA applet terminated.
	 */
	var returnCode:ErrorReturnCode;

	/**
	 * The EULA version that the end user has agreed to.
	 */
	var eulaVersion:UInt16;
}

/**
 * Constructor for creating Applet Error Popup.
 * 
 * ## Warning:
 * - Sometimes crashes on Emulator.
 * 
 * @since 1.5.0
 */
@:cppInclude("3ds.h")
@:cppInclude("haxe3ds_Utils.h")
class Error {
	/**
	 * The maximum number of characters in free text to display for the error.
	 */
	public static inline extern final MAX_TEXT_LENGTH = 2048;

	/**
	 * The current type of the error that will be displayed.
	 */
	public var type:ErrorType;

	/**
	 * Which error code to use? Can range from `-32 Bit Integer Limit` (abstract.) to `32 Bit Integer Limit`
	 * 
	 * Example being if you set to `20102`, error code will show up as 002-0102
	 * 
	 * Note: If this variable is set to `0`, defaults to `An error occurred` instead of `Error Code: 000-0000`
	 */
	public var errorCode:UInt32 = 0;

	/**
	 * Language specified by `CFGLanguage` + 1, do not touch this as it can display in a foreign language.
	 */
	public var useLanguage(default, null):UInt16;

	/**
	 * Whether or not you want to lock the user to access home menu while applet is still active, false if you wanna lock it, true if you keep it unlocked.
	 */
	public var homeButton:Bool = true;

	/**
	 * Specifies whether to use software reset.
	 * 
	 * The error EULA applet exits if `true` is specified and the button combination for software reset is pressed.
	 */
	public var softwareReset:Bool;

	/**
	 * After the error is displayed, if `true` is set for whether to display a dialog box and prompt an application jump to System Settings, a dialog box for guiding the user to System Settings is displayed.
	 * 
	 * This just displays the message. The application must perform the application jump.
	 * 
	 * This function ***only*** works if the variable `type` is `CODE` or `CODE_LANGUAGE`.
	 */
	public var appJump:Bool;

	/**
	 * The custom text to display in the error applet, note that this will `substr` this variable by `MAX_TEXT_LENGTH`.
	 * 
	 * Will not show custom text if `type`'s enum doesn't contain TEXT
	 */
	public var text = "An error has occurred.";

	/**
	 * Setups an error configuration so that the applet can understand it and displays it for you.
	 * @param errType The Error Type enum to use.
	 * @param language On which language do you want it say on.
	 */
	public function new(errType:ErrorType = TEXT, language:CFGLanguage = English) {
		this.type = errType;
		this.useLanguage = (cast language) + 1;
	}

	/**
	 * Function to display the Error Applet with their Metadata Class applied aswell.
	 * 
	 * This creates a new typedef stuct for error configuration, sets all the metadata to the configuration, then displays the error.
	 * 
	 * @return Error result indicating what the code has returned.
	 */
	public function display():ErrorResult {
		if (text.length > MAX_TEXT_LENGTH) {
			text = text.substr(0, MAX_TEXT_LENGTH);
		}

		untyped __cpp__('
			errorConf conf = {0 };
			conf.type = type;
			conf.errorCode = errorCode;
			conf.useLanguage = useLanguage;
			conf.homeButton = homeButton;
			conf.softwareReset = softwareReset;
			conf.appJump = appJump;
			errorText(&conf, text.c_str());
			errorDisp(&conf)
		');

		return {
			returnCode: switch untyped __cpp__('conf.returnCode') {
				case 0: NONE;
				case 1: SUCCESS;
				case 2: NOT_SUPPORTED;
				case 10: HOME_BUTTON;
				case 11: SOFTWARE_RESET;
				case 12: POWER_BUTTON;
				default: UNKNOWN;
			},
			eulaVersion: untyped __cpp__('conf.eulaVersion')
		};
	}
}