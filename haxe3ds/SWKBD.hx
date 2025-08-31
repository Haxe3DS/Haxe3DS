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
    @:native("SWKBD_PASSWORD_NONE")
    SWKBD_PASSWORD_NONE;

    /**
     * Characters are concealed immediately.
     */
    @:native("SWKBD_PASSWORD_NONE")
	SWKBD_PASSWORD_HIDE;

    /**
     * Characters are concealed a second after they've been typed.
     */
    @:native("SWKBD_PASSWORD_HIDE_DELAY")
	SWKBD_PASSWORD_HIDE_DELAY;
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

@:cppFileCode("
#include <3ds.h>
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
     * Current type of Software Keyboard to use.
     * 
     * @see SWKBDType Enum
     */
    public var type:Int = 0;

    /**
     * Total buttons specified in argument. (will be `X-1`)
     */
    public var numButtonsM1:Int = 0;

    /**
     * Total text length that can be inputted.
     */
    public var maxTextLen:UInt16 = 0;

    /**
     * Current Password Mode used.
     * 
     * @see `SWKBDPasswordMode` enum for a full list.
     */
    public var passwordMode:Int = 0;

    /**
     * Array of current numpad key.
     * 
     * Index 0: Left key.
     * Index 1: Right key.
     * 
     * Value:
     * - 0: Hides the key.
     * - 1-2: Unicode codepoint (Equivelant to using `"x".code`).
     */
    public var numpadKeys:Array<UInt16> = [0, 0];

    /**
     * Multiline input.
     */
    public var multiline:Bool = false;

    /**
     * Fixed-width mode.
     */
    public var fixedWidth:Bool = false;

    /**
     * Allow the usage of the HOME button.
     */
    public var homeMenu:Bool = false;

    /**
     * Allow the usage of a software-reset combination.
     */
    public var swReset:Bool = false;

    /**
     * Allow the usage of the POWER button.
     */
    public var power:Bool = false;

    /**
     * Darken the top screen when the keyboard is shown.
     */
    public var darkenTopScreen:Bool = false;

    /**
     * The current text hint that shows when nothing is inputted.
     */
    public var hintText:String = "Enter text here.";

    /**
     * Enable predictive input (necessary for Kanji input in JPN systems).
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
     * Basically a standard "Starter Text".
     */
    public var initialText:String = "Initial Text";

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
            SwkbdState out;
            swkbdInit(&out, toSwkbdType(this->type), this->numButtonsM1 + 1, -1);
            out.type = this->type;
            out.num_buttons_m1 = this->numButtonsM1;
            out.max_text_len = this->maxTextLen;
            out.password_mode = this->passwordMode;
            for (int i = 0; i < 2; i++) out.numpad_keys[i] = (*this->numpadKeys)[i];
            out.multiline = this->multiline;
            out.fixed_width = this->fixedWidth;
            out.allow_home = this->homeMenu;
            out.allow_reset = this->swReset;
            out.allow_power = this->power;
            out.darken_top_screen = this->darkenTopScreen ? 1 : 0;
            out.predictive_input = this->predictiveInput;
            swkbdSetHintText(&out, this->hintText.c_str());
            swkbdSetInitialText(&out, this->initialText.c_str());
            swkbdSetValidation(&out, toSwkbdValidInput(this->validInput->index), 0, 0);
            for (int i = 0; i < 3; i++) swkbdSetButton(&out, i == 0 ? SWKBD_BUTTON_LEFT : i == 1 ? SWKBD_BUTTON_MIDDLE : SWKBD_BUTTON_RIGHT, (*this->buttonData)[i]->input.c_str(), (*this->buttonData)[i]->buttonWillSubmit);

            int len = (int)((*this->dict).size());
            if (len != 0) {
                SwkbdDictWord words[len];
                for (int i = 0; i < len; i++) swkbdSetDictWord(&words[i], (*this->dict)[i]->input.c_str(), (*this->dict)[i]->output.c_str());
                swkbdSetDictionary(&out, words, len);
            }

            char output[1700];
            swkbdInputText(&out, output, 1700);
            return std::string(output)
        ');
        return "";
    }
}