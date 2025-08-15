// THIS IS EXTREMELY BUGGY AND I CANNOT FIX THIS MESS IF YALL MAKE A PR THAT FIXES THIS IM GONNA BE PROUD

package haxe3ds;

/*package haxe3ds;

import haxe3ds.CFGU.CFG_Language;

enum ErrorType {
	/**
	 * Displays the infrastructure communications-related error message corresponding to the error code.
	 *
	CODE;

	/**
	 * Displays text passed to this applet.
	 *
	TEXT;

	/**
	 * Displays the EULA.
	 *
	EULA;
    
	/**
	 * Displays a network error message in a specified language.
	 *
	CODE_LANGUAGE;

	/**
	 * Displays text passed to this applet in a specified language.
	 *
	TEXT_LANGUAGE;

	/**
	 * Displays EULA in a specified language.
	 *
	EULA_LANGUAGE;

	/**
	 * Displays the custom error message passed to this applet with automatic line wrapping.
	 *
	TEXT_WORD_WRAP;

	/**
	 * Displays the custom error message with automatic line wrapping and in the specified language.
	 *
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
	 *
	var ?type:ErrorType;

	/**
	 * Which error code to use? Can range from 0 to 9999999
     * 
     * Example being if you set to 20102, error code will show up as 002-0102
	 *
	var ?errorCode:Int;

	/**
	 * Honestly no idea what it's used for.
	 *
	var ?upperScreenFlag:ErrorScreenFlag;

	/**
	 * Language specified by CFG_Language + 1, do not touch it cause it can display in a foreign language.
	 *
	var ?useLanguage:UInt16;

	/**
	 * Whetever or not you want to lock the user to access home menu while applet is still active, false if you wanna lock it, true if you keep it unlocked.
	 *
	var ?homeButton:Bool;

	/**
	 * No idea what it does.
	 *
	var ?softwareReset:Bool;

	/**
	 * No idea what it does, it just does nothing.
	 *
	var ?appJump:Bool;

	/**
	 * Which error code it should return as, just useless.
	 *
	var ?returnCode:ErrorReturnCode;

	/**
	 * No idea what to set it up correctly, usually 0 in source.
	 *
	var ?eulaVersion:UInt16;
};

@:cppInclude("3ds.h")
@:cppFileCode("
errorType getFromClass(std::shared_ptr<haxe3ds::ErrorType> e) {
    switch(e->index) {
        case 0:  return ERROR_CODE;
        case 1:  return ERROR_TEXT;
        case 2:  return ERROR_EULA;
        case 3:  return ERROR_CODE_LANGUAGE;
        case 4:  return ERROR_TEXT_LANGUAGE;
        case 5:  return ERROR_EULA_LANGUAGE;
        case 6:  return ERROR_TEXT_WORD_WRAP;
        case 7:  return ERROR_TEXT_LANGUAGE_WORD_WRAP;
        default: return ERROR_CODE;
    }
}
    
CFG_Language getFromCFGC(std::shared_ptr<haxe3ds::CFG_Language> e) {
    switch(e->index) {
        case 0:  return CFG_LANGUAGE_DEFAULT;
        case 1:  return CFG_LANGUAGE_JP;
        case 2:  return CFG_LANGUAGE_EN;
        case 3:  return CFG_LANGUAGE_FR;
        case 4:  return CFG_LANGUAGE_DE;
        case 5:  return CFG_LANGUAGE_IT;
        case 6:  return CFG_LANGUAGE_ES;
        case 7:  return CFG_LANGUAGE_ZH;
        case 8:  return CFG_LANGUAGE_KO;
        case 9:  return CFG_LANGUAGE_NL;
        case 10: return CFG_LANGUAGE_PT;
        case 11: return CFG_LANGUAGE_RU;
        case 12: return CFG_LANGUAGE_TW;
    }
}
    
errorReturnCode getFromERC(std::shared_ptr<haxe3ds::ErrorReturnCode> e) {
	switch(e->index) {
		case 0: return ERROR_UNKNOWN;
		case 1: return ERROR_NONE;
		case 2: return ERROR_SUCCESS;
		case 3: return ERROR_NOT_SUPPORTED;
		case 4: return ERROR_HOME_BUTTON;
		case 5: return ERROR_SOFTWARE_RESET;
		case 6: return ERROR_POWER_BUTTON;
	}
}")
class Error {
    /**
     * Setups a error configuration so that the applet can understand it and display it for you.
     * @param errType The ErrorType enum to use.
     * @param language On which language do you want it say on.
     * @return A hand made Error Configuration struct.
     *
    public static function setup(errType:ErrorType, language:CFG_Language):ErrorConfig {
        var configExport:ErrorConfig = {};
        untyped __cpp__('
            errorConf conf;
            errorInit(&conf, getFromClass(errType), getFromCFGC(language));
            configExport->type            = std::make_shared<haxe3ds::ErrorType>(conf.type);
            configExport->errorCode       = conf.errorCode;
            configExport->upperScreenFlag = std::make_shared<haxe3ds::ErrorScreenFlag>(conf.upperScreenFlag);
            configExport->useLanguage     = conf.useLanguage;
            configExport->homeButton      = conf.homeButton;
            configExport->softwareReset   = conf.softwareReset;
            configExport->appJump         = conf.appJump;
            configExport->returnCode      = std::make_shared<haxe3ds::ErrorReturnCode>(conf.returnCode);
            configExport->eulaVersion     = conf.eulaVersion;
        ');
        return configExport;
    }

    /**
     * Begins displaying the error applet configuration.
     * @param config The error config setted up.
     * @param textToSet The text to use as, so that it's converted to be compatible with error applet.
     *
    public static function display(config:ErrorConfig, textToSet:String):Void {
        untyped __cpp__('
            errorConf conf;
            conf.type            = getFromClass(config->type.value());
            conf.errorCode       = config->errorCode.value();
            conf.upperScreenFlag = config->upperScreenFlag.value()->index == 0 ? ERROR_NORMAL : ERROR_STEREO;
            conf.useLanguage     = config->useLanguage.value();
            conf.homeButton      = config->homeButton.value();
            conf.softwareReset   = config->softwareReset.value();
            conf.appJump         = config->appJump.value();
            conf.returnCode      = getFromERC(config->returnCode.value());
            conf.eulaVersion     = config->eulaVersion.value();
            errorText(&conf, textToSet.c_str());
            errorDisp(&conf);
        ');
    }
}*/