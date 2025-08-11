package hx3ds;

extern class Key {
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
	 * The Circle Pad's X Position, it can be -155 to 155
	 */
	var dx:Int;

	/**
	 * The Circle Pad's Y Position, it can be -155 to 155
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

/**
 * HID service.
 * @see http://3dbrew.org/wiki/HID_Services
 * @see http://3dbrew.org/wiki/HID_Shared_Memory
 */
@:cppInclude("3ds.h")
class HID {
	/**
	 * Scans HID for input data.
	 */
	@:native("hidScanInput")
	public static function scanInput():Void {};

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
}