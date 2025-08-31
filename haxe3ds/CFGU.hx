package haxe3ds;

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
 * CFGU (Configuration) Service
 */
@:cppInclude("3ds.h")
class CFGU {
    /**
     * Initializes CFGU.
     */
    @:native("cfguInit")
    public static function init() {};
    
    /**
     * Exits CFGU.
     */
    @:native("cfguExit")
    public static function exit() {};

    /**
     * Gets the system's language.
     * @return The current language the console is in (0 = English, 1 = French, 2 = German, etc).
     * @see https://github.com/devkitPro/libctru/blob/e09a49a08fa469bc08fb62e9d29bfe6407c0232a/libctru/include/3ds/services/cfgu.h#L21-L36
     * @see CFG_Language struct
     */
    public static function getSystemLanguage():UInt8 {
    	var language:UInt8 = 0;
    	untyped __cpp__("CFGU_GetSystemLanguage(&language)");
        return language;
    };

    /**
     * Gets whether the system is a 2DS.
     * @return true if the system is a 2DS, false otherwise.
     */
    public static function isUsing2DS():Bool {
        var out:UInt8 = 0;
        untyped __cpp__("CFGU_GetModelNintendo2DS(&out)");
        return out == 0;
    }
}