package haxe3ds.applet;

import haxe3ds.Types.Result;

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
#include <string.h>

struct VCSELConfig {
    bool homeButton;
    bool softwareReset;
    u8 padding1[6];
    u8 reserved[24];
};

struct VCSELInput {
    u16 titleText[64];
    u32 filterFillType;
    u8 reserved[256 - 2 * 64 - 1];
};

struct VCSELOutput {
    u32 returnCode;
    u16 filePath[262];
    u8 reserved[496];
};

struct VCSELParameter {
    u32 version;
    VCSELConfig config;
    VCSELInput input;
    VCSELOutput output;
};
')
class VoiceSelector {
    /**
     * The length maximum for the voice selector.
     */
    public static var MAX_TITLE_LENGTH(default, null):Int = 64;

    /**
     * The text to be displayed on the bottom screen above, maximum `MAX_TITLE_LENGTH`.
     */
    public var text:String = "Choose a sound.";

    /**
     * The filter to use for the audio.
     */
    public var filter:VoiceSelFilter = ANY_PERCENT;

    /**
     * Whetever or not you want to enable the HOME Menu.
     */
    public var homeMenu:Bool = true;

    /**
     * Whetever or not you want to enable the Software Reset Key Combination.
     */
    public var softwareReset:Bool = false;

    /**
     * Constructor for the voice selector.
     */
    public function new() {}

    /**
     * Displays your configured selection and starts the SNOTE applet.
     * @return The result from SNOTE that was spewed out.
     */
    public function display():VoiceSelResult {
        text = text.substr(0, MAX_TITLE_LENGTH);
        var ret:Result = 0;

        untyped __cpp__('
            VCSELParameter param;
            memset(&param, 0, sizeof(VCSELParameter));

            param.config.homeButton = this->homeMenu;
            param.config.softwareReset = this->softwareReset;
            utf8_to_utf16(param.input.titleText, (u8*)this->text.c_str(), 64);
            param.input.filterFillType = this->filter;

            ret = APT_PrepareToStartLibraryApplet(APPID_SNOTE_AP);
            if (R_FAILED(ret)) {
                goto cleanup;
            }

            aptSetMessageCallback(NULL, &param.output);
            aptLaunchLibraryApplet(APPID_SNOTE_AP, (void*)&param, 0x524, 0);
            aptSetMessageCallback(NULL, NULL);

            cleanup:
        ');

        return {
            result: ret,
            returnCode: switch (untyped __cpp__('param.output.returnCode')) {
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
            codeInt: untyped __cpp__('param.output.returnCode'),
            filePath: untyped __cpp__('u16ToString(param.output.filePath, sizeof(param.output.filePath))')
        };
    }
}