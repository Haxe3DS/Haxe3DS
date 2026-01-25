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
	 * 
	 * Does return `UNKNOWN`?
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
@:cppFileCode('
#include <3ds.h>
#include "haxe3ds_Utils.h"

haxe3ds::applet::ErrorReturnCode rcToHX(errorReturnCode c) {
	using ec = haxe3ds::applet::ErrorReturnCode_obj;
	switch(c) {
		case ERROR_UNKNOWN: ec::UNKNOWN_dyn();
		case ERROR_NONE: ec::NONE_dyn();
		case ERROR_SUCCESS: ec::SUCCESS_dyn();
		case ERROR_NOT_SUPPORTED: ec::NOT_SUPPORTED_dyn();
		case ERROR_HOME_BUTTON: ec::HOME_BUTTON_dyn();
		case ERROR_SOFTWARE_RESET: ec::SOFTWARE_RESET_dyn();
		case ERROR_POWER_BUTTON: ec::POWER_BUTTON_dyn();
		default: ec::UNKNOWN_dyn(); // ????
	}
}')
class Error {
	/**
	 * The maximum number of characters in free text to display for the error.
	 */
	public static inline final MAX_TEXT_LENGTH:Int = 2048;

	/**
	 * The current type of the error that will be displayed, this value cannot be modified except when creating in a constructor.
	 */
	public var type(default, null):ErrorType;

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
	public var useLanguage:UInt16;

	/**
	 * Whether or not you want to lock the user to access home menu while applet is still active, false if you wanna lock it, true if you keep it unlocked.
	 */
	public var homeButton:Bool;

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
	public var text:String = "An error has occurred.";

	/**
	 * Setups an error configuration so that the applet can understand it and displays it for you.
	 * @param errType The Error Type enum to use.
	 * @param language On which language do you want it say on.
	 */
	public function new(errType:ErrorType = TEXT, language:CFGLanguage = English) {
		untyped __cpp__('
			errorConf conf;
			errorInit(&conf, (errorType)errType, (CFG_Language)language)
		');

		this.type = errType;
		this.appJump = untyped __cpp__('conf.appJump');
		this.softwareReset = untyped __cpp__('conf.softwareReset');
		this.homeButton = untyped __cpp__('conf.homeButton');
		this.useLanguage = untyped __cpp__('conf.useLanguage');
	}

	/**
	 * Begins displaying the error applet configuration.
	 * @return Result of the error, `returnCode` is null.
	 */
	public function display():ErrorResult {
		this.text = this.text.substr(0, MAX_TEXT_LENGTH);

		untyped __cpp__('
			errorConf conf;
			conf.type = this->type;
			conf.errorCode = this->errorCode;
			conf.useLanguage = this->useLanguage;
			conf.homeButton = this->homeButton;
			conf.softwareReset = this->softwareReset;
			conf.appJump = this->appJump;
			errorText(&conf, this->text.c_str());
			errorDisp(&conf)
		');

		return {
			returnCode: untyped __cpp__('rcToHX(conf.returnCode)'),
			eulaVersion: untyped __cpp__('conf.eulaVersion')
		};
	}
}