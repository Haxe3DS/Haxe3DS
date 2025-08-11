package hx3ds;

enum GfxScreen_t {
	/**
	 * The 3DS's top screen. Resolution at 400x240.
	 */
	@:native("GFX_TOP")
	GFX_TOP;

	/**
	 * The 3DS's bottom screen. Resolution at 320x240.
	 */
	@:native("GFX_BOTTOM")
	GFX_BOTTOM;
}

/**
 * CFGU (Configuration) Service
 */
class CFGU {
    /**
     * Initializes CFGU.
     */
    @:native("cfguInit")
    public static function init():Void {};
    
    /**
     * Gets the system's language.
     * @param language Pointer to write the language to.
     * @see https://github.com/devkitPro/libctru/blob/e09a49a08fa469bc08fb62e9d29bfe6407c0232a/libctru/include/3ds/services/cfgu.h#L21-L36
     */
    public static function getSystemLanguage():UInt8 {
    	var language:UInt8 = 0;
    	untyped __cpp__("CFGU_GetSystemLanguage(&language)");
    	return language;
    };
    
    /**
     * Exits CFGU.
     */
    @:native("cfguExit")
    public static function exit():Void {};
}