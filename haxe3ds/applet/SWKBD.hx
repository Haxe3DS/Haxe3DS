package haxe3ds.applet;

import cxx.num.UInt16;

/**
 * The types that you can use for your Software Keyboard, they do stuff differently.
 */
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

/**
 * A password like mode for delay hiding, or just hiding instantly.
 */
enum SWKBDPasswordMode {
	/**
	 * Characters are not concealed/masked.
	 */
	NONE;

	/**
	 * Characters are concealed/masked immediately.
	 */
	HIDE;

	/**
	 * Characters are concealed/masked a second after they've been typed.
	 */
	HIDE_DELAY;
}

/**
 * Valid input handler.
 */
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

/**
 * The literal button data.
 */
typedef SWKBDButtonData = {
	/**
	 * Current text provided, maximum 16 characters.
	 */
	var input:String;

	/**
	 * Whetever or not it should acts like a "OK / SUBMIT TEXT" button.
	 */
	var buttonWillSubmit:Bool;
}

/**
 * Dictionary Input/Output
 */
typedef SWKBDDict = {
	/**
	 * Example would be if you use "lenny" as in.
	 */
	var input:String;

	/**
	 * And if you set the output to ( ͡° ͜ʖ ͡°), it will be this.
	 */
	var output:String;
}

/**
 * The Callback Types that's only used for the `callbackFN` function.
 */
enum SWKBDCallbackTypes {
	/**
	 * Specifies that the input is valid.
	 */
	OK;

	/**
	 * Displays an error message, then closes the keyboard.
	 */
	CLOSE;

	/**
	 * Displays an error message and continues displaying the keyboard.
	 */
	CONTINUE;
}

/**
 * The return typedef that can be used for the rest of the callback session.
 */
typedef SWKBDCallbackReturn = {
	/**
	 * The Output Message to use, it must not be `OK` for `result`.
	 */
	var outMessage:String;

	/**
	 * Result Enum to use.
	 */
	var resultCB:SWKBDCallbackTypes;
}

/**
 * Filters to use in the SWKBD.
 */
enum SWKBDFilter {
	/**
	 * The number of numbers that can be input is restricted.
	 */
	DIGITS;

	/**
	 * Input of the at sign (@) is prohibited.
	 */
	AT;

	/**
	 * Input of the percent symbol (%) is prohibited.
	 */
	PERCENT;

	/**
	 * Input of the backslash (\\) is prohibited.
	 */
	BACKSLASH;

	/**
	 * Input of profanity in strings that are displayed on the screen is prohibited.
	 */
	PROFANITY;

	/**
	 * Text checking is performed by the application.
	 */
	CALLBACK;
}

/**
 * The class of the applet call-up library for the LIBCTRU software keyboard.
 * 
 * If the version of the software keyboard applet library used by the application does not match the SDK version supported by the System Updater in use, the software keyboard applet will sometimes fail to start. If the software keyboard applet does not start, apply the most recent System Updater.
 * 
 * @since 1.1.0
 */
@:cppFileCode('
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
}

SwkbdCallbackResult haxe3ds::applet::SWKBDHandler::callbackOut(void* user, const char** ppMessage, const char* text, size_t textlen) {
	haxe3ds::applet::SWKBDHandler* handler = static_cast<haxe3ds::applet::SWKBDHandler*>(user);
	if (handler->callbackFN != nullptr) {
		std::shared_ptr<haxe3ds::applet::SWKBDCallbackReturn> out = handler->callbackFN(std::string(text));
		*ppMessage = out->outMessage.c_str();

		switch(out->resultCB->index) {
			case 0: return SWKBD_CALLBACK_OK;
			case 1: return SWKBD_CALLBACK_CLOSE;
			case 2: return SWKBD_CALLBACK_CONTINUE;
		}
	}

	return SWKBD_CALLBACK_OK;
}')
@:headerInclude("haxe3ds_services_GFX.h")
@:headerClassCode("static SwkbdCallbackResult callbackOut(void* user, const char** ppMessage, const char* text, size_t textlen);")
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
	 * Total text length that can be inputted. (Read-Only)
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
	 * Where:
	 * - 0: Hides the key.
	 * - Any Number: Unicode Codepoint (Equivelant to using `"x".code`).
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
	public var softwareReset:Bool = false;

	/**
	 * Allow the usage of the POWER button.
	 * 
	 * If it's set to false, pressing the power button will not bring you to the "In Sleep Mode, the system can..." screen.
	 */
	public var powerButton:Bool = false;

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
	 * Variable callback to check for custom inputs from whatever you've specified.
	 * 
	 * Example Callback:
	 * ```
this.callbackFN = input -> {
	if (input == "awesome") {
		return {
			outMessage: "Awesome Indeed.",
			resultCB: CLOSE
		};
	}

	return {
		outMessage: "",
		resultCB: OK
	}
};
	 */
	public var callbackFN:String->SWKBDCallbackReturn = s -> {
		// ok wow thanks reflaxe.cpp
		var callback:SWKBDCallbackReturn = {
			outMessage: "",
			resultCB: OK
		};

		return callback;
	};

	/**
	 * Initializes software keyboard status.
	 * @param type Keyboard type, see `SWKBDType` enum.
	 * @param numButtons Number of dialog buttons to display (1, 2 or 3).
	 * @param maxTextLength Maximum number of UTF-16 code units that input text can have (or -1 to let Haxe3DS use a big default).
	 */
	public function new(type:SWKBDType = NORMAL, numButtons:Int = 1, maxTextLength:Int = -1) {
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
			out.allow_reset = this->softwareReset;
			out.allow_power = this->powerButton;
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

			if (this->callbackFN != nullptr) {
				swkbdSetFilterCallback(&out, &haxe3ds::applet::SWKBDHandler::callbackOut, this);
			}

			char output[1700];
			swkbdInputText(&out, output, 1700);
		');

		return untyped __cpp__('std::string(output)');
	}
}