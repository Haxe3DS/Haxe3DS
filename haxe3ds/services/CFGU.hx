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
@:cppInclude("3ds.h")
class CFGU {
    /**
     * Initializes CFGU.
     */
    public static function init() {
        untyped __cpp__('
            cfguInit();
            CFGU_GetSystemLanguage(&systemLanguage);

            u8 r;
            CFGU_GetModelNintendo2DS(&r);
            isUsing2DSModel = r == 0;
        ');
    };
    
    /**
     * Exits CFGU.
     */
    @:native("cfguExit")
    public static function exit() {};

    /**
     * Variable for the current system language used.
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
}