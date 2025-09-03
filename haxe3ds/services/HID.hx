package haxe3ds.services;

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
	 *  Accelerometer X
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
 * @see http://3dbrew.org/wiki/HID_Services
 * @see http://3dbrew.org/wiki/HID_Shared_Memory
 * @see http://3dbrew.org/wiki/IR_Services
 * @see http://3dbrew.org/wiki/IRRST_Shared_Memory
 * 
 * @since 1.0.0 only for C-Stick Support
 */
@:cppInclude("3ds.h")
class HID {
	/**
	 * Initializes HID.
	 */
	@:native("hidInit")
	public static function init() {};

	/**
	 * Exits HID.
	 */
	@:native("hidExit")
	public static function exit() {};

	/**
	 * Scans HID for input data.
	 */
	@:native("hidScanInput") // lol
	public static function scanInput() untyped __cpp__("irrstScanInput()");

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
	 * @param typeof Integer typeof, 0/other numbers = pressed, 1 = held, 2 = up
	 * @return Lists of UInt32 keys pressed.
	 */
	public static function keyArray(typeof:Int = 0):Array<UInt32> {
		var ret:Array<UInt32> = [];
		final f:UInt32->Bool = typeof == 1 ? keyHeld : typeof == 2 ? keyUp : keyPressed;

		for (key in [
			Key.A, Key.B, Key.CPAD_DOWN, Key.CPAD_LEFT, Key.CPAD_RIGHT, Key.CPAD_UP, Key.CSTICK_DOWN, Key.CSTICK_LEFT, Key.CSTICK_RIGHT, Key.ZR,
			Key.CSTICK_UP, Key.DDOWN, Key.DLEFT, Key.DRIGHT, Key.DUP, Key.L, Key.R, Key.SELECT, Key.START, Key.TOUCH, Key.X, Key.Y, Key.ZL
		]) {
			if (f(key)) {
				ret.push(key);
			}
		}

		return ret;
	}

	/**
	 * Reads the current circle pad position.
	 * @return CirclePosition Data for dx and dy
	 */
	public static function circlePadRead():CirclePosition {
		var pos:CirclePosition = {dx: 0, dy: 0};
		untyped __cpp__("circlePosition temp;
hidCircleRead(&temp);
pos->dx = temp.dx;
pos->dy = temp.dy");
		return pos;
	}

	/**
	 * Reads the current C-Stick position, ONLY is available in New 3DS Models!!!.
	 * @return CirclePosition Data for dx and dy
	 */
	public static function cStickRead():CirclePosition {
		var pos:CirclePosition = {dx: 0, dy: 0};
		untyped __cpp__("circlePosition temp;
irrstCstickRead(&temp);
pos->dx = temp.dx;
pos->dy = temp.dy");
		return pos;
	}

	/**
	 * Reads the current touch position.
	 * @return TouchPosition Data for px and py.
	 */
	public static function touchPadRead():TouchPosition {
		var pos:TouchPosition = {px: 0, py: 0};
		untyped __cpp__("touchPosition temp;
hidTouchRead(&temp);
pos->px = temp.px;
pos->py = temp.py");
		return pos;
	}

	/**
	 * Reads the current accelerometer data.
	 * @return Output of the accelerometer data.
	 */
	public static function accelRead():AccelVector {
		var acc:AccelVector = {x: 0, y: 0, z: 0};
		untyped __cpp__("accelVector temp;
hidAccelRead(&temp);
acc->x = temp.x;
acc->y = temp.y;
acc->z = temp.z");
		return acc;
	}

	/**
	 * Reads the current gyroscope data.
	 * @return Output of the gyroscope data.
	 */
	public static function gyroRead():AngularRate {
		var ang:AngularRate = {x: 0, y: 0, z: 0};
		untyped __cpp__("angularRate temp;
hidGyroRead(&temp);
ang->x = temp.x;
ang->y = temp.y;
ang->z = temp.z");
		return ang;
	}

	/**
	 * Enables the accelerometer.
	 */
	@:native("HIDUSER_EnableAccelerometer")
	public static function enableAccelerometer() {};

	/**
	 * Disables the accelerometer.
	 */
	@:native("HIDUSER_DisableAccelerometer")
	public static function disableAccelerometer() {};

	/**
	 * Enables the gyroscope.
	 */
	@:native("HIDUSER_EnableGyroscope")
	public static function enableGyroscope() {};

	/**
	 * Disables the gyroscope.
	 */
	@:native("HIDUSER_DisableGyroscope")
	public static function disableGyroscope() {};

	/**
	 * Gets the current volume slider value. (0-63)
	 * @return Current volume slider value.
	 */
	public static function getSoundVolume():UInt8 {
		var v:UInt8 = 0;
		untyped __cpp__("HIDUSER_GetSoundVolume(&v)");
		return v;
	};
}