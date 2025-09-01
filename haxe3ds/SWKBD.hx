package haxe3ds;

import cxx.num.UInt16;

enum SWKBDType {
	/**
	 * Normal keyboard with several pages (QWERTY/accents/symbol/mobile)
	 */
	NORMAL;

	/**
	 * QWERTY keyboard only.
	 */
	QWERTY;

	/**
	 * Number pad.
	 */
	NUMPAD;

	/**
	 * On JPN systems, a text keyboard without Japanese input capabilities, otherwise same as `NORMAL`.
	 */
	WESTERN;
}

enum SWKBDPasswordMode {
    /**
     * Characters are not concealed.
     */
    NONE;

    /**
     * Characters are concealed immediately.
     */
	HIDE;

    /**
     * Characters are concealed a second after they've been typed.
     */
	HIDE_DELAY;
}

enum SWKBDValidInputHandler {
    /**
     * All inputs are accepted.
     */
    ANYTHING;

    /**
     * Empty inputs are not accepted.
     */
    NOTEMPTY;

    /**
     * Empty or blank inputs (consisting solely of whitespace) are not accepted.
     */
    NOTEMPTY_NOTBLANK;

    /**
     * Blank inputs (consisting solely of whitespace) are not accepted, but empty inputs are.
     */
    NOTBLANK;

    /**
     * The input must have a fixed length (specified by maxTextLength in `maxTextLen`).
     */
    FIXEDLEN;
}

typedef SWKBDButtonData = {
    /**
     * Current text provided, maximum 16 characters.
     */
    input:String,

    /**
     * Whetever or not it should acts like a "OK / SUBMIT TEXT" button.
     */
    buttonWillSubmit:Bool
}

typedef SWKBDDict = {
    /**
     * Example would be if you use "lenny" as in.
     */
    input:String,

    /**
     * And if you set the output to ( ͡° ͜ʖ ͡°), it will be this.
     */
    output:String
}

enum SWKBDFilter {
    /**
     * Disallow the use of more than a certain number of digits (0 or more)
     */
    DIGITS;

    /**
     * Disallow the use of the @ sign.
     */
    AT;

    /**
     * Disallow the use of the % sign.
     */
    PERCENT;

    /**
     * Disallow the use of the \ sign.
     */
    BACKSLASH;

    /**
     * Disallow profanity using Nintendo's profanity filter.
     */
    PROFANITY;

    /**
     * Use a callback in order to check the input.
     */
    CALLBACK;
}

@:cppFileCode("
#include <3ds.h>
#include <iostream>

SwkbdType toSwkbdType(int index) {
    switch(index) {
        case 0: default: return SWKBD_TYPE_NORMAL;
        case 1: return SWKBD_TYPE_QWERTY;
        case 2: return SWKBD_TYPE_NUMPAD;
        case 3: return SWKBD_TYPE_WESTERN;
    }
}
    
SwkbdValidInput toSwkbdValidInput(int index) {
    switch(index) {
        case 0: default: return SWKBD_ANYTHING;
        case 1: return SWKBD_NOTEMPTY;
        case 2: return SWKBD_NOTEMPTY_NOTBLANK;
        case 3: return SWKBD_NOTBLANK;
        case 4: return SWKBD_FIXEDLEN;
    }
}")

/**
 * Software keyboard applet.
 * 
 * Some of the features from SWKBD are not implemented yet, will be available in the future or so.
 * 
 * @since 1.1.0
 */
class SWKBDHandler {
    /**
     * Current type of Software Keyboard to use. (Read-Only)
     * 
     * @see SWKBDType Enum
     */
    public var type(default, null):Int = 0;

    /**
     * Total buttons specified in argument. (will be `X-1`) (Read-Only)
     */
    public var numButtonsM1(default, null):Int = 0;

    /**
     * Total text length that can be inputted.
     */
    public var maxTextLen(default, null):UInt16 = 0;

    /**
     * Current Password Mode used.
     * 
     * @see `SWKBDPasswordMode` enum for a full list.
     */
    public var passwordMode:SWKBDPasswordMode = NONE;

    /**
     * Array of current numpad key.
     * 
     * Indexes:
     * - 0: Left key.
     * - 1: Right key.
     * 
     * Value:
     * - 0: Hides the key.
     * - Any Unicode: Unicode codepoint (Equivelant to using `"x".code`).
     */
    public var numpadKeys:Array<UInt16> = [0, 0];

    /**
     * Multiline input.
     * 
     * I don't even know what it does.
     */
    public var multiline:Bool = false;

    /**
     * Fixed-width mode.
     * 
     * This basically sets the maximum character length to 32 instead of whatever's max length on `maxTextLen`.
     */
    public var fixedWidth:Bool = false;

    /**
     * Allow the usage of the HOME button.
     * 
     * If it's set to false, HOME Menu will be disabled and a icon will appear.
     */
    public var homeMenu:Bool = false;

    /**
     * Allow the usage of a software-reset combination.
     */
    public var swReset:Bool = false;

    /**
     * Allow the usage of the POWER button.
     * 
     * If it's set to false, pressing the power button will not bring you to the "In Sleep Mode, the system can..." screen.
     */
    public var power:Bool = false;

    /**
     * If it's set to true, the screen from above will be darken so that the SWKBD will be more focused.
     */
    public var darkenTopScreen:Bool = false;

    /**
     * The current text hint that shows when nothing is inputted.
     */
    public var hintText:String = "Enter text here.";

    /**
     * Enable predictive input (necessary for Kanji input in JPN systems).
     * 
     * If disabled, predictive input will be hidden and won't be able to choose a variety of words. This also disables `dict`
     */
    public var predictiveInput:Bool = true;

    /**
     * Current array data for buttons.
     * 
     * Indexes:
     * - 0 = Left button. (secondary button)
     * - 1 = Middle button.
     * - 2 = Right button (primary button).
     * 
     * #### Warning:
     * 
     * Popping/Removing something from an array or length is less than 3 will THROW AN EXCEPTION!
     */
    public var buttonData:Array<SWKBDButtonData> = [];

    /**
     * Current initial text that a software keyboard will display on launch.
     * 
     * Basically a standard Starter Text that will be used.
     */
    public var initialText:String = "";

    /**
     * Current array of a dictionary/prediction, can be pushed to add even more dicts.
     * 
     * Example:
     * If in is "lenny" and output will be "( ͡° ͜ʖ ͡°)", typing "lenny" would result "( ͡° ͜ʖ ͡°)" being added in.
     * 
     * Note:
     * Seems to be useless at the moment.
     */
    public var dict:Array<SWKBDDict> = [];

    /**
     * Current validation for inputs.
     */
    public var validInput:SWKBDValidInputHandler = ANYTHING;

    /**
     * Default to the QWERTY page when the keyboard is shown.
     * 
     * Example being if you're using AZERTY and this is enabled, it will be defaulted to QWERTY!
     */
    public var defaultQWERTY:Bool = false;

    /**
     * Lists of filters to use, don't use duplicate filter flags!
     * 
     * @see `SWKBDFilter` enum.
     */
    public var filterFlags:Array<SWKBDFilter> = [];

    /**
     * Specify how many maximum digits to use, will be enabled if `filterFlags` has `DIGITS`!
     * 
     * If set to 0 and `filterFlags` has `DIGITS`, it will disallow uses of digits.
     */
    public var maxDigits:Int = 0;

    /**
     * Initializes software keyboard status.
     * @param type Keyboard type, see `SWKBDType` enum.
     * @param numButtons Number of dialog buttons to display (1, 2 or 3).
     * @param maxTextLength Maximum number of UTF-16 code units that input text can have (or -1 to let Haxe3DS use a big default).
     */
    public function new(type:SWKBDType, numButtons:Int, maxTextLength:Int) {
        untyped __cpp__('
            SwkbdState out;
            swkbdInit(&out, toSwkbdType(type2->index), numButtons, maxTextLength);
            this->type = out.type;
            this->numButtonsM1 = out.num_buttons_m1;
            this->maxTextLen = out.max_text_len;
        ');

        for (i in 0...3) {
            buttonData.push({
                input: "OK",
                buttonWillSubmit: true
            });
        }
    }

    /**
     * Launches SWKBD with the current params that you've set!
     * @return Current text inputted, maximum 1700 characters.
     */
    public function launch():String {
        untyped __cpp__('
            u32 filter = 0;
            for (auto &&e : *this->filterFlags) {
                switch(e->index) {
                    case 0: default: filter += SWKBD_FILTER_DIGITS; break;
                    case 1: filter += SWKBD_FILTER_AT; break;
                    case 2: filter += SWKBD_FILTER_PERCENT; break;
                    case 3: filter += SWKBD_FILTER_BACKSLASH; break;
                    case 4: filter += SWKBD_FILTER_PROFANITY; break;
                    case 5: filter += SWKBD_FILTER_CALLBACK; break;
                }
            }

            SwkbdState out;
            static SwkbdStatusData swkbdStatus;
            static SwkbdLearningData swkbdLearning;
            swkbdInit(&out, toSwkbdType(this->type), this->numButtonsM1 + 1, this->maxTextLen);

            out.type = this->type;
            out.num_buttons_m1 = this->numButtonsM1;
            out.password_mode = this->passwordMode->index;
            for (int i = 0; i < 2; i++) out.numpad_keys[i] = (*this->numpadKeys)[i];
            out.multiline = this->multiline;
            out.fixed_width = this->fixedWidth;
            out.allow_home = this->homeMenu;
            out.allow_reset = this->swReset;
            out.allow_power = this->power;
            out.darken_top_screen = this->darkenTopScreen ? 1 : 0;
            out.default_qwerty = this->defaultQWERTY ? 1 : 0;
            out.predictive_input = this->predictiveInput;
            swkbdSetHintText(&out, this->hintText.c_str());
            swkbdSetInitialText(&out, this->initialText.c_str());
            swkbdSetValidation(&out, toSwkbdValidInput(this->validInput->index), filter, this->maxDigits);
            for (int i = 0; i < 3; i++) swkbdSetButton(&out, i == 0 ? SWKBD_BUTTON_LEFT : i == 1 ? SWKBD_BUTTON_MIDDLE : SWKBD_BUTTON_RIGHT, (*this->buttonData)[i]->input.c_str(), (*this->buttonData)[i]->buttonWillSubmit);

            int len = (int)((*this->dict).size());
            if (len != 0 && this->predictiveInput) {
                SwkbdDictWord words[len];
                for (int i = 0; i < len; i++) swkbdSetDictWord(&words[i], (*this->dict)[i]->input.c_str(), (*this->dict)[i]->output.c_str());
                swkbdSetDictionary(&out, words, len);
                swkbdSetStatusData(&out, &swkbdStatus, true, true);
                swkbdSetLearningData(&out, &swkbdLearning, true, true);
            }

            char output[1700];
            swkbdInputText(&out, output, 1700);
            return std::string(output)
        ');
        return "";
    }
}