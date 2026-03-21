package haxe3ds.applet;

import haxe3ds.types.Result;

/**
 * The Voice Selector Filtering, Values can only be 0 to 4.
 * @since 1.5.0
 */
enum abstract VoiceSelFilter(Int) {
	/**
	 * All audios of any length is supported.
	 */
	var ANY_PERCENT = 0;

	/**
	 * The maximum length of audios is 10 seconds.
	 */
	var LOWER_THAN_100 = 1;

	/**
	 * The maximum length of audios is 7.5 seconds.
	 */
	var LOWER_THAN_75 = 2;

	/**
	 * The maximum length of audios is 5 seconds.
	 */
	var LOWER_THAN_50 = 3;

	/**
	 * The maximum length of audios is 2.5 seconds.
	 */
	var LOWER_THAN_25 = 4;
}

/**
 * Return code. Stores the return code that indicates the reason why the SNOTE applet terminated.
 * 
 * @since 1.5.0
 */
enum VoiceSelReturnCode {
	/**
	 * Abnormal end.
	 */
	UNKNOWN;

	/**
	 * A config value is invalid.
	 */
	INVALID_CONFIG;

	/**
	 * Ended abnormally because of insufficient memory.
	 */
	OUT_OF_MEMORY;

	/**
	 * Ended normally (no audio was selected).
	 */
	NONE;

	/**
	 * Ended normally (audio was selected).
	 */
	SUCCESS;

	/**
	 * HOME was pressed.
	 */
	HOME_BUTTON;

	/**
	 * A button combination was pressed that causes a software reset.
	 */
	SOFTWARE_RESET;

	/**
	 * The POWER Button was pressed.
	 */
	POWER_BUTTON;
}

/**
 * The selector result.
 * 
 * @since 1.5.0
 */
typedef VoiceSelResult = {
	/**
	 * The file path that's been selected by the user.
	 * 
	 * It's mostly stored in this directory: `sdmc:/Nintendo 3DS/private/00020500/voice/01/V13303.m4a`
	 * 
	 * Where:
	 * - `00020500` is the Title ID for the Nintendo 3DS Sound.
	 * - `01` is the folder page.
	 * - `13` is the file number.
	 * - `30` is the icon color.
	 * - `3` Is the icon shape.
	 */
	var filePath:String;

	/**
	 * The return code that was received by the applet.
	 */
	var returnCode:VoiceSelReturnCode;

	/**
	 * The code in integer instead of an enum.
	 */
	var codeInt:Int;

	/**
	 * The result code if something went wrong.
	 */
	var result:Result;
}

/**
 * Class for the Nintendo 3DS Voice Selector (SNOTE) applet.
 * 
 * ## Warning:
 * This will not launch on azahar emulator, always check if it's a real 3ds by doing `Env.isUsing3DS`!
 * 
 * @since 1.5.0
 */
@:cppFileCode('
#include "haxe3ds_Utils.h"
#include <3ds.h>
#include <string.h>

struct VCSELParameter {
	u32 version;

	bool homeButton;
	bool softwareReset;
	u8 padding1[6];
	u8 reserved1[24];

	u16 titleText[64];
	u32 filterFillType;
	u8 reserved2[127];

	u32 returnCode;
	u16 filePath[262];
	u8 reserved[496];
};
')
class VoiceSelector {
	/**
	 * The length maximum for the voice selector.
	 */
	public static inline final MAX_TITLE_LENGTH = 64;

	/**
	 * The text to be displayed on the bottom screen above, maximum `MAX_TITLE_LENGTH`.
	 */
	public var text = "Choose a sound.";

	/**
	 * The filter to use for the audio.
	 */
	public var filter:VoiceSelFilter = ANY_PERCENT;

	/**
	 * Whether or not you want to enable the HOME Menu.
	 */
	public var homeMenu = true;

	/**
	 * Whether or not you want to enable the Software Reset Key Combination.
	 */
	public var softwareReset:Bool;

	/**
	 * Constructor for the voice selector.
	 */
	public function new() {}

	/**
	 * Displays your configured selection and starts the SNOTE applet.
	 * @return The result from SNOTE that was spewed out.
	 */
	public function display():VoiceSelResult {
		if (text.length > MAX_TITLE_LENGTH) {
			text = text.substr(0, MAX_TITLE_LENGTH);
		}

		var ret:Result = 0;
		untyped __cpp__('
			VCSELParameter param = { 0};
			param.homeButton = this->homeMenu;
			param.softwareReset = this->softwareReset;
			param.filterFillType = this->filter;
			TRANSFER(this->text.c_str(), param.titleText);

			if R_FAILED(ret = APT_PrepareToStartLibraryApplet(APPID_SNOTE_AP)) {
				goto cleanup;
			}

			aptSetMessageCallback(NULL, &param);
			aptLaunchLibraryApplet(APPID_SNOTE_AP, (void*)&param, 0x524, 0);
			aptSetMessageCallback(NULL, NULL);

			cleanup:
		');

		return {
			result: ret,
			returnCode: switch (untyped __cpp__('param.returnCode')) {
				case -1: UNKNOWN;
				case -2: INVALID_CONFIG;
				case -3: OUT_OF_MEMORY;
				case  0: NONE;
				case  1: SUCCESS;
				case 10: HOME_BUTTON;
				case 11: SOFTWARE_RESET;
				case 12: POWER_BUTTON;
				default: UNKNOWN;
			},
			codeInt: untyped __cpp__('param.returnCode'),
			filePath: untyped __cpp__('u16ToString(param.filePath)')
		};
	}
}