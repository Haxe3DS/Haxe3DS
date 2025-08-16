#include "haxe3ds_Utils.h"

errorType getFromET(std::shared_ptr<haxe3ds::ErrorType> e) {
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
		default: return CFG_LANGUAGE_DEFAULT;
    }
}
    
errorReturnCode getFromERC(std::shared_ptr<haxe3ds::ErrorReturnCode> e) {
	switch(e->index) {
		case 0:  return ERROR_UNKNOWN;
		case 1:  return ERROR_NONE;
		case 2:  return ERROR_SUCCESS;
		case 3:  return ERROR_NOT_SUPPORTED;
		case 4:  return ERROR_HOME_BUTTON;
		case 5:  return ERROR_SOFTWARE_RESET;
		case 6:  return ERROR_POWER_BUTTON;
		default: return ERROR_UNKNOWN;
	}
}