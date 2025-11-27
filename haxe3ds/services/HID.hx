package haxe3ds.services;

@:dontGenerateDynamic
class Key {
	@:native("KEY_START")
	public static var START:UInt32;
	
	@:native("KEY_A")
	public static var A:UInt32;

	@:native("KEY_B")
	public static var B:UInt32;
	
	@:native("KEY_Y")
	public static var Y:UInt32;
	
	@:native("KEY_X")
	public static var X:UInt32;
	
	@:native("KEY_SELECT")
	public static var SELECT:UInt32;
	
	@:native("KEY_DLEFT")
	public static var DLEFT:UInt32;		

	@:native("KEY_DDOWN")
	public static var DDOWN:UInt32;	

	@:native("KEY_DUP")
	public static var DUP:UInt32;

	@:native("KEY_DRIGHT")
	public static var DRIGHT:UInt32;

	@:native("KEY_R")
	public static var R:UInt32;

	@:native("KEY_L")
	public static var L:UInt32;

	/**
	 * New 3DS only
	 */
	@:native("KEY_ZL")
	public static var ZL:UInt32;
	
	/**
	 * New 3DS only
	 */
	@:native("KEY_ZR")
	public static var ZR:UInt32;
	
	/**
	 * Not actually provided by HID
	 */
	@:native("KEY_TOUCH")
	public static var TOUCH:UInt32;
	
	/**
	 * New 3DS only
	 */
	@:native("KEY_CSTICK_RIGHT")
	public static var CSTICK_RIGHT:UInt32;
	
	/**
	 * New 3DS only
	 */
	@:native("KEY_CSTICK_LEFT")
	public static var CSTICK_LEFT:UInt32;
	
	/**
	 * New 3DS only
	 */
	@:native("KEY_CSTICK_UP")
	public static var CSTICK_UP:UInt32;
	
	/**
	 * New 3DS only
	 */
	@:native("KEY_CSTICK_DOWN")
	public static var CSTICK_DOWN:UInt32;
	
	@:native("KEY_CPAD_RIGHT")
	public static var CPAD_RIGHT:UInt32;
	
	@:native("KEY_CPAD_LEFT")
	public static var CPAD_LEFT:UInt32;

	@:native("KEY_CPAD_UP")
	public static var CPAD_UP:UInt32;
	
	@:native("KEY_CPAD_DOWN")
	public static var CPAD_DOWN:UInt32;

	/**
	 * D-Pad Up or Circle Pad Up
	 */
	@:native("KEY_UP")
	public static var UP:UInt32;

	/**
	 * D-Pad Down or Circle Pad Down
	 */
	@:native("KEY_DOWN")
	public static var DOWN:UInt32;

	/**
	 * D-Pad Left or Circle Pad Left
	 */
	@:native("KEY_LEFT")
	public static var LEFT:UInt32;

	/**
	 * D-Pad Right or Circle Pad Right
	 */
	@:native("KEY_RIGHT")
	public static var RIGHT:UInt32;
}

typedef CirclePosition = {
	/**
	 * The Circle Pad's X Position, it can be -155 to 155 (-146 to 146 if C-Stick)
	 */
	var dx:Int;

	/**
	 * The Circle Pad's Y Position, it can be -155 to 155 (-146 to 146 if C-Stick)
	 */
	var dy:Int;
}

typedef TouchPosition = {
	/**
	 * The Touch's X Position, it can be 0 to 319 (5 to 314 on Original Hardware). Not touching will lead the value being 0.
	 */
	var px:Int;

	/**
	 * The Touch's Y Position, it can be 0 to 239 (5 to 234 on Original Hardware). Not touching will lead the value being 0.
	 */
	var py:Int;
}

typedef AccelVector = {
	/**
	 * Accelerometer X
	 */
	var x:Int;

	/**
	 * Accelerometer Y
	 */
	var y:Int;

	/**
	 * Accelerometer Z
	 */
	var z:Int;
};

typedef AngularRate = {
	/**
	 * Roll
	 */
	var x:Int;

	/**
	 * Pitch
	 */
	var y:Int;

	/**
	 * Yaw
	 */
	var z:Int;
};

/**
 * HID and IRRST services.
 * 
 * This is for enabling inputs to read from the 3DS, this also handles Circle Pad, C Stick, Touch, and miscelaneous ones such as Accelerometer and Angular
 */
@:cppInclude("haxe3ds_services_GFX.h")
class HID {
	/**
	 * Scans HID for input data.
	 * 
	 * Automatically called from `APT.mainLoop()`
	 */
	public static function scanInput() untyped __cpp__("hidScanInput(); irrstScanInput()");

	/**
	 * Checks whetever a key is pressed or not.
	 * @param key The key from extern Button to check whetever it's pressed.
	 * @return true if pressed, false if not.
	 */
	public static function keyPressed(key:UInt32):Bool return untyped __cpp__("hidKeysDown() & key");

	/**
	 * Checks whetever a key is held or not.
	 * @param key The key from extern Button to check whetever it's held.
	 * @return true if held, false if not.
	 */
	public static function keyHeld(key:UInt32):Bool return untyped __cpp__("hidKeysHeld() & key");

	/**
	 * Checks whetever a key is up or not.
	 * @param key The key from extern Button to check whetever it's up.
	 * @return true if up, false if not.
	 */
	public static function keyUp(key:UInt32):Bool return untyped __cpp__("hidKeysUp() & key");

	/**
	 * Returns a large variety of key pressed/held/up.
	 * 
	 * @param typeof Integer typeof, 1 = held, 2 = up, other = pressed.
	 * @return Lists of UInt32 keys pressed.
	 */
	public static function keyArray(typeof:Int = 0):Array<UInt32> {
		var ret:Array<UInt32> = [];
		final f:UInt32->Bool = typeof == 1 ? keyHeld : typeof == 2 ? keyUp : keyPressed;

		final arr:Array<UInt32> = [Key.A, Key.B, Key.CPAD_DOWN, Key.CPAD_LEFT, Key.CPAD_RIGHT, Key.CPAD_UP, Key.CSTICK_DOWN, Key.CSTICK_LEFT, Key.CSTICK_RIGHT, Key.ZR,Key.CSTICK_UP, Key.DDOWN, Key.DLEFT, Key.DRIGHT, Key.DUP, Key.L, Key.R, Key.SELECT, Key.START, Key.TOUCH, Key.X, Key.Y, Key.ZL];
		for (key in arr)
			if (f(key))
				ret.push(key);

		return ret;
	}

	/**
	 * Variable for the Circle Pad Data.
	 */
	public static var circlePad(get, null):CirclePosition;
	static function get_circlePad():CirclePosition {
		untyped __cpp__("
			circlePosition temp;
			hidCircleRead(&temp)
		");

		return {
			dx: untyped __cpp__('temp.dx'),
			dy: untyped __cpp__('temp.dy')
		};
	}

	/**
	 * Variable for the C Stick Data, this is only available for the New Nintendo 3DS.
	 */
	public static var cStick(get, null):CirclePosition;
	static function get_cStick():CirclePosition {
		untyped __cpp__("
			circlePosition temp;
			irrstCstickRead(&temp)
		");

		return {
			dx: untyped __cpp__('temp.dx'),
			dy: untyped __cpp__('temp.dy')
		};
	}

	/**
	 * Variable for the C Stick Data, this is only available for the New Nintendo 3DS.
	 */
	public static var touch(get, null):TouchPosition;
	static function get_touch():TouchPosition {
		untyped __cpp__("
			touchPosition temp;
			hidTouchRead(&temp)
		");

		return {
			px: untyped __cpp__('temp.px'),
			py: untyped __cpp__('temp.py')
		};
	}

	/**
	 * Variable for the acceleration from the 3DS system.
	 */
	public static var accel(get, null):AccelVector;
	static function get_accel():AccelVector {
		untyped __cpp__("
			accelVector temp;
			hidAccelRead(&temp)
		");

		return {
			x: untyped __cpp__('temp.x'),
			y: untyped __cpp__('temp.y'),
			z: untyped __cpp__('temp.z')
		};
	}

	/**
	 * Variable for the gyroscope data from the 3DS system.
	 */
	public static var angular(get, null):AngularRate;
	static function get_angular():AngularRate {
		untyped __cpp__("
			angularRate temp;
			hidGyroRead(&temp);
		");

		return {
			x: untyped __cpp__('temp.x'),
			y: untyped __cpp__('temp.y'),
			z: untyped __cpp__('temp.z')
		};
	}

	/**
	 * Variable property that gets or sets the accelerometer's status.
	 * 
	 * `Set` will call either `HIDUSER_EnableAccelerometer` if true, or `HIDUSER_DisableAccelerometer` if false.
	 */
	@:isVar public static var accelerometer(null, set):Bool;
	static function set_accelerometer(accelerometer:Bool):Bool {
		untyped __cpp__('accelerometer ? HIDUSER_EnableAccelerometer() : HIDUSER_DisableAccelerometer()');
		return accelerometer;
	}

	/**
	 * Variable property that gets or sets the gyroscope's status.
	 * 
	 * `Set` will call either `HIDUSER_EnableGyroscope` if true, or `HIDUSER_DisableGyroscope` if false.
	 */
	@:isVar public static var gyroscope(null, set):Bool;
	static function set_gyroscope(gyroscope:Bool):Bool {
		untyped __cpp__('gyroscope ? HIDUSER_EnableGyroscope() : HIDUSER_DisableGyroscope()');
		return gyroscope;
	}

	/**
	 * Variable property that gets the current volume slider value. (0-63).
	 * 
	 * `Get` will call `HIDUSER_GetSoundVolume` and returns the variable.
	 */
	public static var soundVolume(get, null):UInt8;
	static function get_soundVolume():UInt8 {
		var v:UInt8 = 0;
		untyped __cpp__("HIDUSER_GetSoundVolume(&v)");
		return v;
	}
}