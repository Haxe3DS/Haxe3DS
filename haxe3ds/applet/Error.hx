package haxe3ds.applet;

import haxe3ds.services.CFGU.CFG_Language;

/**
 * The type of applet to call.
 */
enum ErrorType {
	/**
	 * Displays the infrastructure communications-related error message corresponding to the error code.
	 * 
	 * Also known as `Network Error`.
	 */
	CODE;

	/**
	 * Displays text passed to this applet.
	 */
	TEXT;

	/**
	 * Displays the EULA.
	 */
	EULA;
	
	/**
	 * Displays a network error message in a specified language.
	 */
	CODE_LANGUAGE;

	/**
	 * Displays text passed to this applet in a specified language.
	 */
	TEXT_LANGUAGE;

	/**
	 * Displays EULA in a specified language.
	 */
	EULA_LANGUAGE;

	/**
	 * Displays the custom error message passed to this applet with automatic line wrapping.
	 */
	TEXT_WORD_WRAP;

	/**
	 * Displays the custom error message with automatic line wrapping and in the specified language.
	 */
	TEXT_LANGUAGE_WORD_WRAP;
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
#include "haxe3ds_Utils.h"

errorType getFromET(int e) {
	switch(e) {
		case 0: default: return ERROR_CODE;
		case 1: return ERROR_TEXT;
		case 2: return ERROR_EULA;
		case 3: return ERROR_CODE_LANGUAGE;
		case 4: return ERROR_TEXT_LANGUAGE;
		case 5: return ERROR_EULA_LANGUAGE;
		case 6: return ERROR_TEXT_WORD_WRAP;
		case 7: return ERROR_TEXT_LANGUAGE_WORD_WRAP;
	}
}

std::shared_ptr<haxe3ds::applet::ErrorReturnCode> rcToHX(errorReturnCode c) {
	using namespace haxe3ds::applet;
	switch(c) {
		case ERROR_UNKNOWN: default: return ErrorReturnCode::UNKNOWN();
		case ERROR_NONE: return ErrorReturnCode::NONE();
		case ERROR_SUCCESS: return ErrorReturnCode::SUCCESS();
		case ERROR_NOT_SUPPORTED: return ErrorReturnCode::NOT_SUPPORTED();
		case ERROR_HOME_BUTTON: return ErrorReturnCode::HOME_BUTTON();
		case ERROR_SOFTWARE_RESET: return ErrorReturnCode::SOFTWARE_RESET();
		case ERROR_POWER_BUTTON: return ErrorReturnCode::POWER_BUTTON();
	}
}')
class Error {
	/**
	 * The maximum number of characters in free text to display for the error.
	 */
	public static var MAX_TEXT_LENGTH(default, null):UInt16 = 2048;

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
	 * Language specified by `CFG_Language` + 1, do not touch this as it can display in a foreign language.
	 */
	public var useLanguage:UInt16;

	/**
	 * Whetever or not you want to lock the user to access home menu while applet is still active, false if you wanna lock it, true if you keep it unlocked.
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
	public var text:String;

	/**
	 * Setups an error configuration so that the applet can understand it and displays it for you.
	 * @param errType The Error Type enum to use.
	 * @param language On which language do you want it say on.
	 */
	public function new(errType:ErrorType = TEXT, language:CFG_Language = English) {
		untyped __cpp__('
			errorConf conf;
			errorInit(&conf, getFromET(errType->index), getFromCFGC(language->index))
		');

		this.type = errType;
		this.appJump = untyped __cpp__('conf.appJump');
		this.softwareReset = untyped __cpp__('conf.softwareReset');
		this.homeButton = untyped __cpp__('conf.homeButton');
		this.useLanguage = untyped __cpp__('conf.useLanguage');
		this.text = "An error has occurred.";
	}

	/**
	 * Begins displaying the error applet configuration.
	 */
	public function display():ErrorResult {
		this.text = this.text.substr(0, MAX_TEXT_LENGTH);

		untyped __cpp__('
			errorConf conf;
			conf.type = getFromET(this->type->index);
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