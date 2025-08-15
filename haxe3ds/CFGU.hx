package haxe3ds;

/**
 * Configuration language values.
 */
enum CFG_Language {
    /**
     * Use system language in errorInit
     */
    @:native("CFG_LANGUAGE_DEFAULT") Default;

    @:native("CFG_LANGUAGE_JP") Japanese;
    @:native("CFG_LANGUAGE_EN") English;
    @:native("CFG_LANGUAGE_FR") French;
    @:native("CFG_LANGUAGE_DE") German;
    @:native("CFG_LANGUAGE_IT") Italian;
    @:native("CFG_LANGUAGE_ES") Spanish;
    @:native("CFG_LANGUAGE_ZH") SimplifiedChinese;
    @:native("CFG_LANGUAGE_KO") Korean;
    @:native("CFG_LANGUAGE_NL") Dutch;
    @:native("CFG_LANGUAGE_PT") Portugese;
    @:native("CFG_LANGUAGE_RU") Russian;
    @:native("CFG_LANGUAGE_TW") TraditionalChinese;
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
    public static function init():Void {};
    
    /**
     * Exits CFGU.
     */
    @:native("cfguExit")
    public static function exit():Void {};

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