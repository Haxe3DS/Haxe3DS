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
	Portuguese;
	Russian;
	TraditionalChinese;
}

/**
 * The restriction bitmask applied to CFGU's Parental Controls.
 * 
 * Note: BIT 12 - 30 is missing and no it isn't a bug.
 * 
 * @since 1.5.0
 */
enum CFGURestrictBitmask {
	/**
	 * `BIT 0`
	 * 
	 * Global Parental Controls Enable.
	 */
	GPCE;

	/**
	 * `BIT 1`
	 * 
	 * Internet Browser.
	 */
	INTERNET_BROWSER;

	/**
	 * `BIT 2`
	 * 
	 * 3D Images.
	 */
	THREED_IMAGES;

	/**
	 * `BIT 3`
	 * 
	 * Sharing Images/Audio/Video/Long Text Data (UGC)
	 */
	SHARING;

	/**
	 * `BIT 4`
	 * 
	 * Online Interaction
	 */
	ONLINE;

	/**
	 * `BIT 5`
	 * 
	 * StreetPass
	 */
	STREETPASS;

	/**
	 * `BIT 6`
	 * 
	 * Friend Registration
	 */
	FRIEND_REGISTER;

	/**
	 * `BIT 7`
	 * 
	 * DS Download Play
	 */
	DS_DP;
	
	/**
	 * `BIT 8`
	 * 
	 * Nintendo 3DS Shopping Services (eShop / EC Applet)
	 */
	ESHOP;

	/**
	 * `BIT 9`
	 * 
	 * View Distributed Videos
	 */
	DISTRIBUTED;

	/**
	 * `BIT 10`
	 * 
	 * Miiverse (View)
	 */
	MIIVERSE_VIEW;

	/**
	 * `BIT 11`
	 * 
	 * Miiverse (Post)
	 */
	MIIVERSE_POST;

	/**
	 * `BIT 31`
	 * 
	 * Child Online Privacy Protection.
	 * 
	 * @see `CFGU.isCanadaUSA`
	 */
	COPPA;
}

/**
 * Parental Controls Settings.
 * @since 1.5.0
 */
typedef CFGUParental = {
	/**
	 * An array of restriction bitmask.
	 */
	var restriction:Array<CFGURestrictBitmask>;

	/**
	 * The rating system that is used for configuration.
	 */
	var ratingSystem:UInt8;

	/**
	 * Maximum age that is restricted.
	 */
	var maxAllowedAge:UInt8;

	/**
	 * The secret question type that's used.
	 * 
	 * Possible variables:
	 * - `0`: What did you call your first pet?
	 * - `1`: Where were you born?
	 * - `2`: What is your favourite sports team?
	 * - `3`: What was your favourite birthday present?
	 * - `4`: What is your favourite film?
	 * - `5`: If you could go anywhere, where would you go?
	 * - `6`: Custom Question.
	 */
	var secretQuestion:UInt8;

	/**
	 * The PIN attached to the Parental Controls.
	 * 
	 * It's actual input is this: `0x3X3X 0x3X3X`.
	 */
	var pin:UInt16;

	/**
	 * The secret answer that is used.
	 */
	var secretAnswer:String;

	/**
	 * Whetever or not if Parental Controls is enabled or not.
	 */
	var enabled:Bool;
}

/**
 * The username for this console.
 * @since 1.5.0
 */
typedef CFGUUsername = {
	/**
	 * The current console's username.
	 */
	var name:String;

	/**
	 * Whetever or not this username contains profanity or not.
	 */
	var hasProfanity:Bool;

	/**
	 * NGWord version the username was last checked with. If this value is less than the u32 stored in the NGWord CFA "romfs:/version.dat", the system then checks the username string with the bad-word list CFA again, then updates this field with the value from the CFA.
	 */
	var version:UInt32;
}

/**
 * Settings for the screen brightness and power saving.
 * @since 1.6.0
 */
typedef CFGUBacklightControl = {
	/**
	 * Whether or not power saving is enabled by the option in `HOME Menu Settings` > `Power-Saving Mode`.
	 */
	var powerSaving:Bool;

	/**
	 * The backlight brightness of the screen that's used, can be set easily in `HOME Menu Settings` > `Screen Brightness`.
	 * 
	 * Minumum 1, Maximum 5.
	 */
	var brightness:UInt8;
};

/**
 * CFGU (Configuration) Service, home to system languge and the checker for 2DS Models
 */
@:cppInclude('haxe3ds_Utils.h')
class CFGU {
	/**
	 * Initializes CFGU and sets up other variables for it to register.
	 */
	public static function init() {
		untyped __cpp__('
			cfguInit();

			u8 r;
			std::deque<std::string> arr = {"Japanese","English","French","German","Italian","Spanish","Simplified Chinese","Korean","Dutch","Portuguese","Russian","Traditional Chinese"};
			CFGU_GetSystemLanguage(&r);
			language = arr[r];

			arr = {"JPN","USA","EUR","AUS","CHN","KOR","TWN"};
			CFGU_SecureInfoGetRegion(&r);
			region = arr[r];

			CFGU_GetRegionCanadaUSA(&r);
			isCanadaUSA = r == 1;

			CFGU_IsNFCSupported(&supportsNFC);

			arr = {"CTR","SPR","KTR","FTR","RED","JAN"};
			CFGU_GetSystemModel(&r);
			model = arr[r];

			struct Block {
				u16 user[10];
				u8 nullterm;
				u16 ngWord;
				u32 ngWordv;
			};
			Block usern;
			CFGU_GetConfigInfoBlk2(sizeof(Block), 0x000A0000, &usern);
			username->name = u16ToString(usern.user, 10);
			username->hasProfanity = (bool)usern.ngWord;
			username->version = usern.ngWordv;

			struct Birth {
				u8 month;
				u8 day;
			};
			Birth birt;
			CFGU_GetConfigInfoBlk2(sizeof(Birth), 0x000A0001, &birt);
			arr = {"January", "February", "March", "April", "May", "June","July", "August", "September", "October", "November", "December"};
			char date[15];
			std::snprintf(date, 15, "%s %02d", arr[birt.month - 1].c_str(), birt.day);
			birthday = date;

			CFGU_GetConfigInfoBlk2(1, 0x00070001, &soundOutput);
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
	 * @since 1.3.0
	 */
	public static var username:CFGUUsername = {name: "", version: 0, hasProfanity: false};

	/**
	 * Variable that gets the System's Current Birthday set by the user, can be modified by going to `System Settings` > `Other Settings` > `Profile` > `User Name`.
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
	public static var birthday(default, null):String;

	/**
	 * Variable string for the current model.
	 * 
	 * Possible Values:
	 * ```
	 * - "CTR" // OLD 3DS	(0)
	 * - "SPR" // OLD 3DS XL (1)
	 * - "KTR" // OLD 2DS	(2)
	 * - "FTR" // NEW 3DS	(3)
	 * - "RED" // NEW 3DS XL (4)
	 * - "JAN" // NEW 2DS XL (5)
	 * ```
	 * 
	 * @since 1.3.0
	 */
	public static var model(default, null):String;

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
	public static var region(default, null):String;

	/**
	 * Variable for the current system language used.
	 * 
	 * Will automatically be set when `CGFU.init` is called.
	 * 
	 * Possible Values:
	 * ```
	 * - "Japanese"			// 0
	 * - "English"			 // 1
	 * - "French"			  // 2
	 * - "German"			  // 3
	 * - "Italian"			 // 4
	 * - "Spanish"			 // 5
	 * - "Simplified Chinese"  // 6
	 * - "Korean"			  // 7
	 * - "Dutch"			   // 8
	 * - "Portuguese"		  // 9
	 * - "Russian"			 // 10
	 * - "Traditional Chinese" // 11
	 * ```
	 * 
	 * @since 1.3.0
	 */
	public static var language(default, null):String;

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
	 * The current sound output mode that's set by the user from `System Settings` > `Other Settings` > `Page 2`.
	 * 
	 * Possible Values:
	 * - `0` - Mono.
	 * - `1` - Stereo.
	 * - `2` - 3D Surround Sound.
	 * 
	 * @since 1.5.0
	 */
	public static var soundOutput(default, null):UInt8;

	/**
	 * Gets the current parental control information, note that if `CFG_GetConfigInfoBlk4` failed, it will return as null.
	 * @return A nicely structured CFGU Parental.
	 * @since 1.5.0
	 */
	public static function getParentalControlInfo():Null<CFGUParental> {
		untyped __cpp__('
			using namespace haxe3ds::services;
			struct Parental {
				u32 restrictionBitmask;
				u32 unknown0x4;
				u8 ratingSystem;
				u8 maxAllowedAge;
				u8 secretQuestion;
				u8 unknown0xB;
				u16 pinCode[4];
				u16 secretAnswer[34];
			};
			Parental out;

			if (R_FAILED(CFG_GetConfigInfoBlk4(0xC0, 0x000C0000, &out))) {
				return nullptr;
			};
			
			std::shared_ptr<std::deque<std::shared_ptr<CFGURestrictBitmask>>> bitmask = std::make_shared<std::deque<std::shared_ptr<haxe3ds::services::CFGURestrictBitmask>>>(std::deque<std::shared_ptr<haxe3ds::services::CFGURestrictBitmask>>{});
			for (int i = 0; i < 32; i++) {
				if (i == 12) i = 31;
				if (BIT(i) & out.restrictionBitmask) {
					switch (i) {
						case 0:  {bitmask->push_front(CFGURestrictBitmask::GPCE()); break;}
						case 1:  {bitmask->push_front(CFGURestrictBitmask::INTERNET_BROWSER()); break;}
						case 2:  {bitmask->push_front(CFGURestrictBitmask::THREED_IMAGES()); break;}
						case 3:  {bitmask->push_front(CFGURestrictBitmask::SHARING()); break;}
						case 4:  {bitmask->push_front(CFGURestrictBitmask::ONLINE()); break;}
						case 5:  {bitmask->push_front(CFGURestrictBitmask::STREETPASS()); break;}
						case 6:  {bitmask->push_front(CFGURestrictBitmask::FRIEND_REGISTER()); break;}
						case 7:  {bitmask->push_front(CFGURestrictBitmask::DS_DP()); break;}
						case 8:  {bitmask->push_front(CFGURestrictBitmask::ESHOP()); break;}
						case 9:  {bitmask->push_front(CFGURestrictBitmask::DISTRIBUTED()); break;}
						case 10: {bitmask->push_front(CFGURestrictBitmask::MIIVERSE_VIEW()); break;}
						case 11: {bitmask->push_front(CFGURestrictBitmask::MIIVERSE_POST()); break;}
						case 31: {bitmask->push_front(CFGURestrictBitmask::COPPA()); break;}
					}
				}
			}

			char numConvert[5];
			sprintf(numConvert, "%u%u%u%u", out.pinCode[0] & 0xF, (out.pinCode[0] >> 8) & 0xF, out.pinCode[1] & 0xF, (out.pinCode[1] >> 8) & 0xF);
			int pin = std::stoi(numConvert);

			std::string strOut;
			for (int i = 0; i < 34; i++) {
				u16 digit = out.secretAnswer[i];
				if (digit == 0) break;
				strOut += digit;
			}
		');

		return {
			restriction: untyped __cpp__('bitmask'),
			ratingSystem: untyped __cpp__('out.ratingSystem'),
			maxAllowedAge: untyped __cpp__('out.maxAllowedAge'),
			secretQuestion: untyped __cpp__('out.secretQuestion'),
			pin: untyped __cpp__('pin'),
			secretAnswer: untyped __cpp__('strOut'),
			enabled: untyped __cpp__('*(u64*)&out & 1')
		};
	}

	/**
	 * Checks if the pin code matches with the Parental Controls pin.
	 * @param code The pin in U16 to use.
	 * @return `true` if it exactly matches, `false` if it ain't.
	 * @since 1.5.0
	 */
	public static function checkPCPinCode(code:UInt16):Bool {
		final pin:CFGUParental = getParentalControlInfo();
		if (pin == null) return true;
		return pin.pin == code;
	}

	/**
	 * Gets the backlight control typedef settings stored in block 0x00050001.
	 * @return `null` if `CFG_GetConfigInfoBlk8` failed to get, else returns the contents.
	 * @since 1.6.0
	 */
	public static function getBacklightControl():Null<CFGUBacklightControl> {
		untyped __cpp__('
			struct BCB {
				bool pse;
				u8 bl;
			};
			BCB block;

			if (R_FAILED(CFG_GetConfigInfoBlk8(sizeof(BCB), 0x00050001, &block)))
				return nullptr;
		');

		return {
			powerSaving: untyped __cpp__('block.pse'),
			brightness: untyped __cpp__('block.bl')
		}
	}
}