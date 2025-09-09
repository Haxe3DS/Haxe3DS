package haxe3ds.services;

/**
 * Configuration language values.
 */
enum CFG_Language {
    /**
     * Use system language in errorInit
     */
    Default;

    Japanese;
    English;
    French;
    German;
    Italian;
    Spanish;
    SimplifiedChinese;
    Korean;
    Dutch;
    Portugese;
    Russian;
    TraditionalChinese;
}

/**
 * CFGU (Configuration) Service, home to system languge and the checker for 2DS Models
 */
@:cppFileCode('
#include <3ds.h>
#include "haxe3ds_Utils.h"
')
class CFGU {
    /**
     * Initializes CFGU and sets up other variables for it to register.
     */
    public static function init() {
        untyped __cpp__('
            cfguInit();
            CFGU_GetSystemLanguage(&systemLanguage);

            u8 r;
            CFGU_GetModelNintendo2DS(&r);
            isUsing2DSModel = r == 0;

            CFGU_SecureInfoGetRegion(&systemRegion);

            CFGU_GetRegionCanadaUSA(&r);
            isCanadaUSA = r == 1;

            CFGU_GetRegionCanadaUSA(&r);
            systemModel = r;

            CFGU_IsNFCSupported(&supportsNFC);
        ');
    };
    
    /**
     * Exits CFGU.
     */
    @:native("cfguExit")
    public static function exit() {};

    /**
     * (CFG:U) Variable for the current system language used.
     * 
     * Will automatically be set when `CGFU.init` is called.
     * 
     * @see https://www.3dbrew.org/wiki/Config_Services
     */
    public static var systemLanguage(default, null):UInt8;

    /**
     * Variable for returning if the model is a 2DS instead of a 3DS.
     * 
     * Will automatically be set when `CGFU.init` is called.
     * 
     * Available since:
     * - 3DS: 6.0.0-11
     * - Haxe3DS: 1.1.0
     */
    public static var isUsing2DSModel(default, null):Bool;

    /**
     * The current system region.
     * 
     * Will automatically be set when `CGFU.init` is called.
     * 
     * Variable returns:
     * - `0`: Japan.
     * - `1`: USA.
     * - `2`: Europe.
     * - `3`: Australia.
     * - `4`: China.
     * - `5`: Korea.
     * - `6`: Taiwan.
     */
    public static var systemRegion(default, null):UInt8;

    /**
     * Whetever or not the system is in canada or USA.
     * 
     * Will automatically be set when `CGFU.init` is called.
     */
    public static var isCanadaUSA(default, null):Bool;

    /**
     * The current system model using.
     * 
     * Will automatically be set when `CGFU.init` is called.
     * 
     * Variable returns:
     * - `0`: Old 3DS (CTR)
     * - `1`: Old 3DS XL (SPR)
     * - `2`: New 3DS (KTR)
     * - `3`: Old 2DS (FTR)
     * - `4`: New 3DS XL (RED)
     * - `5`: New 2DS XL (JAN)
     */
    public static var systemModel(default, null):UInt8;

    /**
     * Variable property that checks if NFC (code name: fangate) is supported.
     * 
     * Will automatically be set when `CGFU.init` is called.
     */
    public static var supportsNFC(default, null):Bool;

    /**
     * Clears parental controls
     */
    @:native("CFGI_ClearParentalControls")
    public static function clearParentalControls() {}
}