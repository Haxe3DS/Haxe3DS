package haxe3ds;

import haxe3ds.CFGU.CFG_Language;

enum ErrorType {
	/**
	 * Displays the infrastructure communications-related error message corresponding to the error code.
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

enum ErrorScreenFlag {
	@:native("ERROR_NORMAL") NORMAL;   
	@:native("ERROR_STEREO") STEREO;
}

enum ErrorReturnCode {
	@:native("ERROR_UNKNOWN")        UNKNOWN;
	@:native("ERROR_NONE")           NONE;
	@:native("ERROR_SUCCESS")        SUCCESS;
	@:native("ERROR_NOT_SUPPORTED")  NOT_SUPPORTED;
	@:native("ERROR_HOME_BUTTON")    HOME_BUTTON;
	@:native("ERROR_SOFTWARE_RESET") SOFTWARE_RESET;
	@:native("ERROR_POWER_BUTTON")   POWER_BUTTON;
}

typedef ErrorConfig = {
	/**
	 * Sets up which error type to use as, not necessary to use it since Error.setup() does that for you.
	 */
	var ?type:ErrorType;

	/**
	 * Which error code to use? Can range from 0 to 9999999
     * 
     * Example being if you set to 20102, error code will show up as 002-0102
	 */
	var ?errorCode:Int;

	/**
	 * Honestly no idea what it's used for.
	 */
	var ?upperScreenFlag:ErrorScreenFlag;

	/**
	 * Language specified by CFG_Language + 1, do not touch it cause it can display in a foreign language.
	 */
	var ?useLanguage:UInt16;

	/**
	 * Whetever or not you want to lock the user to access home menu while applet is still active, false if you wanna lock it, true if you keep it unlocked.
	 */
	var ?homeButton:Bool;

	/**
	 * No idea what it does.
	 */
	var ?softwareReset:Bool;

	/**
	 * No idea what it does, it just does nothing.
	 */
	var ?appJump:Bool;

	/**
	 * Which error code it should return as, just useless.
	 */
	var ?returnCode:ErrorReturnCode;

	/**
	 * No idea what to set it up correctly, usually 0 in source.
	 */
	var ?eulaVersion:UInt16;
};

@:cppInclude("3ds.h")
@:cppInclude("haxe3ds_Utils.h")
class Error {
    /**
     * Setups a error configuration so that the applet can understand it and display it for you.
     * @param errType The ErrorType enum to use.
     * @param language On which language do you want it say on.
     * @return A hand made Error Configuration struct.
     */
    public static function setup(errType:ErrorType, language:CFG_Language):ErrorConfig {
	    var configExport:ErrorConfig = {};
	    untyped __cpp__('
	        errorConf conf;
	        errorInit(&conf, getFromET(errType), getFromCFGC(language));
		
	        configExport->type = errType;
	        configExport->errorCode = conf.errorCode;
		
	        configExport->upperScreenFlag = conf.upperScreenFlag == ERROR_STEREO 
	            ? haxe3ds::ErrorScreenFlag::ERROR_STEREO() 
	            : haxe3ds::ErrorScreenFlag::ERROR_NORMAL();
		
	        configExport->useLanguage = conf.useLanguage;
	        configExport->homeButton = conf.homeButton;
	        configExport->softwareReset = conf.softwareReset;
	        configExport->appJump = conf.appJump;
		
	        configExport->returnCode = haxe3ds::ErrorReturnCode::ERROR_SUCCESS();
		
	        configExport->eulaVersion = conf.eulaVersion;
	    ');
	    return configExport;
	}

    /**
     * Begins displaying the error applet configuration, Using an emulator (azahar or citra) and displaying it will throw an uncatchable EXCEPTION! Use your real hardware 3DS to test this instead.
     * @param config The error config setted up.
     * @param textToSet The text to use as, so that it's converted to be compatible with error applet. Will not show custom text if `config` doesn't contain TEXT
     */
    public static function display(config:ErrorConfig, textToSet:String):Void {
	    untyped __cpp__('
	        errorConf conf;
	        conf.type = getFromET(config->type.value());
	        conf.errorCode = config->errorCode.value();
	        conf.upperScreenFlag = config->upperScreenFlag.value()->index == 1 ? ERROR_STEREO : ERROR_NORMAL;
	        conf.useLanguage = config->useLanguage.value();
	        conf.homeButton = config->homeButton.value();
	        conf.softwareReset = config->softwareReset.value();
	        conf.appJump = config->appJump.value();
	        conf.returnCode = getFromERC(config->returnCode.value());
	        conf.eulaVersion = config->eulaVersion.value();
	        errorText(&conf, textToSet.c_str());
	        errorDisp(&conf);
	    ');
	}
}