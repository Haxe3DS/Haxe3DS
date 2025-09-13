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

            u8 r;
            std::deque<std::string> arr = {"Japanese","English","French","German","Italian","Spanish","Simplified Chinese","Korean","Dutch","Portugese","Russian","Traditional Chinese"};
            CFGU_GetSystemLanguage(&r);
            systemLanguage = arr[r];

            arr = {"JPN","USA","EUR","AUS","CHN","KOR","TWN"};
            CFGU_SecureInfoGetRegion(&r);
            systemRegion = arr[r];

            CFGU_GetRegionCanadaUSA(&r);
            isCanadaUSA = r == 1;

            CFGU_IsNFCSupported(&supportsNFC);

            arr = {"CTR","SPR","KTR","FTR","RED","JAN"};
            CFGU_GetSystemModel(&r);
            systemModel = arr[r];

            struct Block {
                u16 username[10];
                u32 zero;
                u32 ngWord;
            };
            Block usern;
            CFGU_GetConfigInfoBlk2(sizeof(Block), 0x000A0000, std::addressof(usern));
            systemUsername = u16ToString(usern.username, 10);

            struct Birth {
                u8 month;
                u8 day;
            };
            Birth birt;
            CFGU_GetConfigInfoBlk2(sizeof(Birth), 0x000A0001, std::addressof(birt));
            arr = {"January", "February", "March", "April", "May", "June","July", "August", "September", "October", "November", "December"};
            char date[15];
            std::snprintf(date, 15, "%s %02d", arr[birt.month - 1].c_str(), birt.day);
            systemBirthday = date
        ');
    };
    
    /**
     * Exits CFGU.
     */
    @:native("cfguExit")
    public static function exit() {};

    /**
     * Variable that gets the System's Current Username set by the user, can be modified by going to `System Settings` > `Other Settings` > `Profile` > `User Name`.
     * 
     * Special thanks to [this repo](https://github.com/joel16/3DSident/blob/next/source/config.cpp#L37) for finding it out.
     * 
     * @since 1.3.0
     */
    public static var systemUsername(default, null):String;

    /**
     * Variable that gets the System's Current Birthday set by the user, can be modified by going to `System Settings` > `Other Settings` > `Profile` > `User Name`.
     * 
     * Special thanks to [this repo](https://github.com/joel16/3DSident/blob/next/source/config.cpp#L51) for finding it out.
     * 
     * Format for string examples:
     * ```
     * - "January 03"
     * - "August 19"
     * - "December 25"
     * ```
     * 
     * @since 1.3.0
     */
    public static var systemBirthday(default, null):String;

    /**
     * Variable string for the current model.
     * 
     * Possible Values:
     * ```
     * - "CTR" // OLD 3DS    (0)
     * - "SPR" // OLD 3DS XL (1)
     * - "KTR" // OLD 2DS    (2)
     * - "FTR" // NEW 3DS    (3)
     * - "RED" // NEW 3DS XL (4)
     * - "JAN" // NEW 2DS XL (5)
     * ```
     * 
     * @since 1.3.0
     */
    public static var systemModel(default, null):String;

    /**
     * Variable string for the current region of this system.
     * 
     * Possible Values:
     * ```
     * - "JPN" // 0
     * - "USA" // 1
     * - "EUR" // 2
     * - "AUS" // 3
     * - "CHN" // 4
     * - "KOR" // 5
     * - "TWN" // 6
     * ```
     * 
     * @since 1.3.0
     */
    public static var systemRegion(default, null):String;

    /**
     * Variable for the current system language used.
     * 
     * Will automatically be set when `CGFU.init` is called.
     * 
     * Possible Values:
     * ```
     * - "Japanese"            // 0
     * - "English"             // 1
     * - "French"              // 2
     * - "German"              // 3
     * - "Italian"             // 4
     * - "Spanish"             // 5
     * - "Simplified Chinese"  // 6
     * - "Korean"              // 7
     * - "Dutch"               // 8
     * - "Portugese"           // 9
     * - "Russian"             // 10
     * - "Traditional Chinese" // 11
     * ```
     * 
     * @since 1.3.0
     */
    public static var systemLanguage(default, null):String;

    /**
     * Whetever or not the system is in canada or USA. This is also known as `CFG:IsCoppacsSupported`
     * 
     * Will automatically be set when `CGFU.init` is called.
     */
    public static var isCanadaUSA(default, null):Bool;

    /**
     * Variable property that checks if NFC (code name: fangate) is supported.
     * 
     * Will automatically be set when `CGFU.init` is called.
     * 
     * @since 1.2.0
     */
    public static var supportsNFC(default, null):Bool;

    /**
     * Clears parental controls
     * 
     * @since 1.2.0
     */
    @:native("CFGI_ClearParentalControls")
    public static function clearParentalControls() {}
}