package haxe3ds.services;

import cpp.UInt16;
import cpp.UInt8;
import cpp.UInt32;

/**
 * Configuration language values.
 */
enum abstract CFGLanguage(Int) {
	/**
	 * Use system language in errorInit
	 */
	var Default = -1;

	var Japanese;
	var English;
	var French;
	var German;
	var Italian;
	var Spanish;
	var SimplifiedChinese;
	var Korean;
	var Dutch;
	var Portuguese;
	var Russian;
	var TraditionalChinese;
}

/**
 * The restriction bitmask applied to CFG's Parental Controls.
 * 
 * Note: BIT 12 - 30 is missing and no it isn't a bug.
 * 
 * @since 1.5.0
 */
enum CFGRestrictBitmask {
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
	 * @see `CFG.isCanadaUSA`
	 */
	COPPA;
}

/**
 * Parental Controls Settings.
 * @since 1.5.0
 */
typedef CFGParental = {
	/**
	 * An array of restriction bitmask.
	 */
	var restriction:Array<CFGRestrictBitmask>;

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
	 * Its actual input is this: `0x3X 0x3X 0x3X 0x3X`.
	 */
	var pin:UInt16;

	/**
	 * The secret answer that is used.
	 */
	var secretAnswer:String;

	/**
	 * Whether or not if Parental Controls is enabled or not.
	 */
	var enabled:Bool;
}

/**
 * The username for this console.
 * @since 1.5.0
 */
typedef CFGUsername = {
	/**
	 * The current console's username.
	 */
	var name:String;

	/**
	 * Whether or not this username contains profanity or not.
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
typedef CFGBacklightControl = {
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
 * CFG (Configuration) Service, home to system languge and the checker for 2DS Models
 */
@:cppFileCode('
#include "haxe3ds_Utils.h"
#include <deque>
#include <string>

typedef struct {
	bool pse;
	u8 bl;
} CFGBC;
')
class CFG {
	/**
	 * Initializes CFG and sets up other variables for it to register.
	 */
	public static function init() {
		untyped __cpp__('
			cfguInit();

			u8 r;
			std::deque<String> arr = {"Japanese","English","French","German","Italian","Spanish","Simplified Chinese","Korean","Dutch","Portuguese","Russian","Traditional Chinese"};
			CFGU_GetSystemLanguage(&r);
			language = arr[r];

			arr = {"JPN","USA","EUR","AUS","CHN","KOR","TWN"};
			CFGU_SecureInfoGetRegion(&r);
			region = arr[r];

			isCanadaUSA = API_GETTER(u8, CFGU_GetRegionCanadaUSA, 0) == 1;
			supportsNFC = API_GETTER(bool, CFGU_IsNFCSupported, false);

			arr = {"CTR","SPR","KTR","FTR","RED","JAN"};
			CFGU_GetSystemModel(&r);
			model = arr[r];

			union {
				u16 user[10];
				u16 ngWord;
				u32 ngWordv;
			} usern;
			CFG_GetConfigInfoBlk8(28, 0x000A0000, &usern);

			union {
				u8 month;
				u8 day;
			} birt;
			CFG_GetConfigInfoBlk8(2, 0x000A0001, &birt);
			arr = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
			char date[15] = { 0 };
			std::snprintf(date, 15, "%s %02d", arr[birt.month - 1].c_str(), birt.day);

			CFG_GetConfigInfoBlk8(1, 0x00070001, &soundOutput);
		');

		birthday = untyped __cpp__('String(date)');

		username = {
			name: untyped __cpp__('u16ToString(usern.user)'),
			hasProfanity: untyped __cpp__('(bool)usern.ngWord'),
			version: untyped __cpp__('(int)usern.ngWordv'),
		}
	};
	
	/**
	 * Exits CFG.
	 */
	@:native("cfguExit")
	public static function exit() {};

	/**
	 * Variable that gets the System's Current Username set by the user, can be modified by going to `System Settings` > `Other Settings` > `Profile` > `User Name`.
	 * 
	 * @since 1.3.0
	 */
	public static var username:CFGUsername;

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
	 * Will automatically be set when `CFG.init` is called.
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
	 * Whether or not the system is in canada or USA. This is also known as `CFG:IsCoppacsSupported`
	 * 
	 * Will automatically be set when `CFG.init` is called.
	 */
	public static var isCanadaUSA(default, null):Bool;

	/**
	 * Variable property that checks if NFC (code name: fangate) is supported.
	 * 
	 * Will automatically be set when `CFG.init` is called.
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
	 * A getter variable returning the Parental Controls Info, Such as restrictions, pin, and more. Config Block stored in 0x000C0000.
	 * @since 1.5.0
	 */
	public static var parentalControlsInfo(get, null):Null<CFGParental>;
	static function get_parentalControlsInfo():Null<CFGParental> {
		untyped __cpp__('
			struct {
				u32 restrictionBitmask;
				u32 unknown0x4;
				u8 ratingSystem;
				u8 maxAllowedAge;
				u8 secretQuestion;
				u8 unknown0xB;
				char pinCode[4];
				u32 pad;
				u16 secretAnswer[34];
				u8 pad2[104];
			} out = { 0};

			if (R_FAILED(CFG_GetConfigInfoBlk8(0xC0, 0x000C0000, &out))) {
				return null();
			}

			using m = haxe3ds::services::CFGRestrictBitmask_obj;
			Array<Dynamic> bitmask = Array_obj<Dynamic>::__new(0);
			for (int i = 0; i < 32; i++) {
				if (i > 11 && i < 31) continue;
				if (BIT(i) & out.restrictionBitmask) {
					switch (i) {
						case 0:  {bitmask->push(m::GPCE_dyn()); break;}
						case 1:  {bitmask->push(m::INTERNET_BROWSER_dyn()); break;}
						case 2:  {bitmask->push(m::THREED_IMAGES_dyn()); break;}
						case 3:  {bitmask->push(m::SHARING_dyn()); break;}
						case 4:  {bitmask->push(m::ONLINE_dyn()); break;}
						case 5:  {bitmask->push(m::STREETPASS_dyn()); break;}
						case 6:  {bitmask->push(m::FRIEND_REGISTER_dyn()); break;}
						case 7:  {bitmask->push(m::DS_DP_dyn()); break;}
						case 8:  {bitmask->push(m::ESHOP_dyn()); break;}
						case 9:  {bitmask->push(m::DISTRIBUTED_dyn()); break;}
						case 10: {bitmask->push(m::MIIVERSE_VIEW_dyn()); break;}
						case 11: {bitmask->push(m::MIIVERSE_POST_dyn()); break;}
						case 31: {bitmask->push(m::COPPA_dyn()); break;}
					}
				}
			}
		');

		return {
			restriction: untyped __cpp__('bitmask'),
			ratingSystem: untyped __cpp__('out.ratingSystem'),
			maxAllowedAge: untyped __cpp__('out.maxAllowedAge'),
			secretQuestion: untyped __cpp__('out.secretQuestion'),
			pin: untyped __cpp__('std::stoi(out.pinCode)'),
			secretAnswer: untyped __cpp__('u16ToString(out.secretAnswer)'),
			enabled: untyped __cpp__('*(u64*)&out & 1')
		};
	}

	/**
	 * Checks if the pin code matches with the Parental Controls pin.
	 * @param code The pin in U16 to use.
	 * @return `true` if it exactly matches, `false` if it ain't or function failed.
	 * @since 1.5.0
	 */
	public static function checkPCPinCode(code:UInt16):Bool {
		final pin:Null<CFGParental> = parentalControlsInfo;
		if (pin == null) return false;
		return pin.pin == code;
	}

	/**
	 * A getter & setter variable for setting the Backlight Control, Stored in Config Block 0x00050001
	 * 
	 * Getter returns the Backlight Control Data, null if failed.
	 * 
	 * Setter Sets the new Data, returns same data if successful, null if failed or data is null.
	 * @since 1.6.0
	 */
	public static var backlightControl(get, set):Null<CFGBacklightControl>;

	static function get_backlightControl():Null<CFGBacklightControl> {
		untyped __cpp__('
			CFGBC block;
			if (R_FAILED(CFG_GetConfigInfoBlk8(2, 0x00050001, &block)))
				return null();
		');

		return {
			powerSaving: untyped __cpp__('block.pse'),
			brightness: untyped __cpp__('block.bl')
		}
	}

	static function set_backlightControl(backlightControl:Null<CFGBacklightControl>):Null<CFGBacklightControl> {
		if (backlightControl == null) {
			return null;
		}

		untyped __cpp__('
			CFGBC block = {.pse = {0}, .bl = {1}};
			if (
				R_FAILED(CFG_SetConfigInfoBlk8(2, 0x00050001, (void*)&block)) ||
				R_FAILED(CFG_UpdateConfigSavegame())
			) return null();
		', backlightControl.powerSaving, backlightControl.brightness);

		return backlightControl;
	}
}