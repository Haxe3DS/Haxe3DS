package haxe3ds.applet;

import cpp.UInt16;
import cpp.UInt32;

/**
 * The types that you can use for your Software Keyboard, they do stuff differently.
 */
enum abstract SWKBDType(Int) {
	/**
	 * Normal keyboard with several pages (QWERTY/accents/symbol/mobile)
	 */
	var NORMAL;

	/**
	 * QWERTY keyboard only.
	 */
	var QWERTY;

	/**
	 * Number pad.
	 */
	var NUMPAD;

	/**
	 * On JPN systems, a text keyboard without Japanese input capabilities, otherwise same as `NORMAL`.
	 */
	var WESTERN;
}

/**
 * A password like mode for delay hiding, or just hiding instantly.
 */
enum abstract SWKBDPasswordMode(Int) {
	/**
	 * Characters are not concealed/masked.
	 */
	var NONE;

	/**
	 * Characters are concealed/masked immediately.
	 */
	var HIDE;

	/**
	 * Characters are concealed/masked a second after they've been typed.
	 */
	var HIDE_DELAY;
}

/**
 * Valid input handler.
 */
enum abstract SWKBDValidInputHandler(Int) {
	/**
	 * All inputs are accepted.
	 */
	var ANYTHING;

	/**
	 * Empty inputs are not accepted.
	 */
	var NOT_EMPTY;

	/**
	 * Empty or blank inputs (consisting solely of whitespace) are not accepted.
	 */
	var NOT_EMPTY_OR_BLANK;

	/**
	 * Blank inputs (consisting solely of whitespace) are not accepted, but empty inputs are.
	 */
	var NOT_BLANK;

	/**
	 * The input must have a fixed length (specified by maxTextLength in `maxTextLen`).
	 */
	var FIXED_LEN;
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
 * The Callback Types that's only used for the `callbackFN` function.
 */
enum abstract SWKBDCallbackTypes(Int) {
	/**
	 * Specifies that the input is valid.
	 */
	var OK;

	/**
	 * Displays an error message, then closes the keyboard.
	 */
	var CLOSE;

	/**
	 * Displays an error message and continues displaying the keyboard.
	 */
	var CONTINUE;
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
	var resultCallback:SWKBDCallbackTypes;
}

/**
 * Filters to use in the SWKBD.
 */
enum abstract SWKBDFilter(UInt32) {
	/**
	 * The number of numbers that can be input is restricted.
	 */
	var DIGITS = 1;

	/**
	 * Input of the at sign (@) is prohibited.
	 */
	var AT;

	/**
	 * Input of the percent symbol (%) is prohibited.
	 */
	var PERCENT = 4;

	/**
	 * Input of the backslash (\\) is prohibited.
	 */
	var BACKSLASH = 8;

	/**
	 * Input of profanity in strings that are displayed on the screen is prohibited.
	 */
	var PROFANITY = 16;

	/**
	 * Text checking is performed by the application.
	 */
	var CALLBACK = 32;
}

/**
 * The class of the applet call-up library for the LIBCTRU software keyboard.
 * 
 * If the version of the software keyboard applet library used by the application does not match the SDK version supported by the System Updater in use, the software keyboard applet will sometimes fail to start. If the software keyboard applet does not start, apply the most recent System Updater.
 * 
 * @since 1.1.0
 */
@:cppFileCode('
SwkbdCallbackResult haxe3ds::applet::SWKBDHandler_obj::callbackOut(void* user, const char** ppMessage, const char* text, size_t textlen) {
	haxe3ds::applet::SWKBDHandler_obj* handler = reinterpret_cast<haxe3ds::applet::SWKBDHandler_obj*>(user);
	if (handler->callbackFN != null()) {
		Dynamic out = handler->callbackFN(String::create(text, textlen));

		*ppMessage = ((String)(out->__Field(String("outMessage"),hx::paccDynamic))).c_str();
		switch((int)out->__Field(String("resultCallback"),hx::paccDynamic)) {
			case 0: return SWKBD_CALLBACK_OK;
			case 1: return SWKBD_CALLBACK_CLOSE;
			case 2: return SWKBD_CALLBACK_CONTINUE;
			default: return SWKBD_CALLBACK_CLOSE;
		}
	}

	return SWKBD_CALLBACK_CLOSE;
}

static SwkbdStatusData swkbdStatus;
static SwkbdLearningData swkbdLearning;')
@:headerInclude("3ds.h")
@:headerClassCode("static SwkbdCallbackResult callbackOut(void* user, const char** ppMessage, const char* text, size_t textlen);")
class SWKBDHandler {
	/**
	 * Current type of Software Keyboard to use. (Read-Only)
	 * 
	 * @see SWKBDType Enum
	 */
	public var type(default, null):SWKBDType;

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
	public var multiline:Bool;

	/**
	 * Fixed-width mode.
	 * 
	 * This basically sets the maximum character length to 32 instead of whatever's max length on `maxTextLen`.
	 */
	public var fixedWidth:Bool;

	/**
	 * Allow the usage of the HOME button.
	 * 
	 * If it's set to `false`, HOME Menu will be disabled and a HOME Menu Icon with a Forbidden Logo will appear.
	 */
	public var homeMenu:Bool;

	/**
	 * Allow the usage of a software-reset combination.
	 */
	public var softwareReset:Bool;

	/**
	 * Allow the usage of the POWER button.
	 * 
	 * If it's set to `false`, pressing the power button will not bring you to the "In Sleep Mode, the system can..." screen.
	 */
	public var powerButton:Bool;

	/**
	 * If it's set to true, the screen from above will be darken so that the SWKBD will be more focused.
	 */
	public var darkenTopScreen:Bool;

	/**
	 * The current text hint that shows when nothing is inputted.
	 */
	public var hintText:String = "Enter text here.";

	/**
	 * Enable predictive input (necessary for Kanji input in JPN systems).
	 * 
	 * If disabled, predictive input will be hidden and won't be able to choose a variety of words, This also disables `dict`.
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
	public var buttonData:Array<SWKBDButtonData> = [for (_ in 0...3) {input: "OK", buttonWillSubmit: true}];

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
	public var dict:Map<String, String> = [];

	/**
	 * Current validation for inputs.
	 */
	public var validInput:SWKBDValidInputHandler = ANYTHING;

	/**
	 * Default to the QWERTY page when the keyboard is shown.
	 * 
	 * Example being if you're using AZERTY and this is enabled, it will be defaulted to QWERTY!
	 */
	public var defaultQWERTY:Bool;

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
	 * this.callbackFN = input -> {
	 * 	if (input == "awesome") {
	 * 		return {
	 * 			outMessage: "Awesome Indeed.",
	 * 			resultCallback: CLOSE
	 * 		};
	 * 	}
	 * 
	 * 	return {
	 * 		outMessage: "",
	 * 		resultCallback: OK
	 * 	}
	 * };
	 */
	public var callbackFN:String->SWKBDCallbackReturn;

	/**
	 * Initializes software keyboard status.
	 * @param type Keyboard type, see `SWKBDType` enum.
	 * @param numButtons Number of dialog buttons to display (1, 2 or 3).
	 * @param maxTextLength Maximum number of UTF-16 code units that input text can have (or -1 to let Haxe3DS use a big default).
	 */
	public function new(type:SWKBDType = NORMAL, numButtons:Int = 1, maxTextLength:Int = -1) {
		this.type = type;
		this.numButtonsM1 = numButtons - 1;
		this.maxTextLen = maxTextLength > 0 ? maxTextLength : 0xFDE8; // FDE8 is the default value from libctru.
	}

	/**
	 * Launches SWKBD with the current params that you've set!
	 * 
	 * Note:
	 * - Will not return a value if there's a callback function.
	 * 
	 * @return Current text inputted, maximum 1700 characters.
	 */
	public function display():String {
		var filter:UInt32 = 0;
		for (flags in filterFlags) {
			final f32:UInt32 = cast flags;
			if ((filter & f32) == 0) {
				filter += f32;
			}
		}

		untyped __cpp__('
			SwkbdState out;
			swkbdInit(&out, (SwkbdType)this->type, this->numButtonsM1 + 1, this->maxTextLen);

			out.type = this->type;
			out.num_buttons_m1 = this->numButtonsM1;
			out.password_mode = this->passwordMode;
			out.multiline = this->multiline;
			out.fixed_width = this->fixedWidth;
			out.allow_home = this->homeMenu;
			out.allow_reset = this->softwareReset;
			out.allow_power = this->powerButton;
			out.darken_top_screen = (u8)this->darkenTopScreen;
			out.default_qwerty = (u8)this->defaultQWERTY;
			out.predictive_input = this->predictiveInput;
			swkbdSetHintText(&out, this->hintText.c_str());
			swkbdSetInitialText(&out, this->initialText.c_str());
			swkbdSetValidation(&out, (SwkbdValidInput)this->validInput, {0}, this->maxDigits);
			for (int i = 0; i < 2; i++) out.numpad_keys[i] = this->numpadKeys->__get(i);
			if (this->callbackFN != null()) swkbdSetFilterCallback(&out, &haxe3ds::applet::SWKBDHandler_obj::callbackOut, this);
		', filter);

		for (i in 0...3) {
			untyped __cpp__('swkbdSetButton(&out, (SwkbdButton){0}, ((String)({1})).c_str(), {2})', i, this.buttonData[i].input, this.buttonData[i].buttonWillSubmit);
		}

		final len:Int = {
			var count:Int = 0;
			for (_ in this.dict.keys()) count++;
			count;
		};

		if (len != 0 && this.predictiveInput) {
			untyped __cpp__('SwkbdDictWord words[len]');

			var iter:Int = 0;
			for (key => value in this.dict.keyValueIterator()) {
				untyped __cpp__('swkbdSetDictWord(&words[{2}], {0}.c_str(), {1}.c_str())', key, value, iter);
				iter++;
			}

			untyped __cpp__('
				swkbdSetDictionary(&out, words, len);
				swkbdSetStatusData(&out, &swkbdStatus, false, true);
				swkbdSetLearningData(&out, &swkbdLearning, false, true)
			');
		}

		untyped __cpp__('
			char output[1700];
			swkbdInputText(&out, output, 1700)
		');

		return untyped __cpp__('String(output)');
	}
}