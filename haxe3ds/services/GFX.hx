package haxe3ds.services;

import haxe3ds.applet.Error;

/**
 * Simple framebuffer API
 *
 * This API provides basic functionality needed to bring up framebuffers for both screens,
 * as well as managing display mode (stereoscopic 3D) and double buffering.
 * It is mainly an abstraction over the gsp service.
 *
 * Please note that the 3DS uses *portrait* screens rotated 90 degrees counterclockwise.
 * Width/height refer to the physical dimensions of the screen; that is, the top screen
 * is 240 pixels wide and 400 pixels tall; while the bottom screen is 240x320.
 */
@:cppInclude("3ds.h")
class GFX {
	/**
	 * Initializes the LCD framebuffers with default parameters
	 */
	@:native("gfxInitDefault")
	public static function initDefault() {
		Error.setup(TEXT, Default);
	};

	/**
	 * Variable property for the GFX's 3D stereoscopic effect.
	 * 
	 * #### Note:
	 * Default value for current3D is `false`/`disabled`.
	 * 
	 * #### Property:
	 * `Get` will call `gfxIs3D` for it's variable.
	 * 
	 * `Set` will call `gfxSet3D` if variable is set.
	 */
	public var current3D(get, set):Bool;
	function get_current3D():Bool {
		return untyped __cpp__('gfxIs3D()');
	}
	function set_current3D(current3D:Bool):Bool {
		untyped __cpp__('gfxSet3D(current3D2)');
		return current3D;
	}

	/**
	 * Variable property for the 3DS's wide screen resolution.
	 * 
	 * #### Note
	 * Wide mode is disabled by default.
	 * 
	 * Wide and stereoscopic 3D modes are mutually exclusive.
	 * 
	 * In wide mode pixels are not square, since scanlines are half as tall as they normally are.
	 * 
	 * #### Property:
	 * `Get` will call `gfxIsWide` for it's variable.
	 * 
	 * `Set` will call `gfxSetWide` with variable specified.
	 */
	public var isWide(get, set):Bool;
	function get_isWide():Bool {
		return untyped __cpp__('gfxIsWide()');
	}
	function set_isWide(isWide:Bool):Bool {
		untyped __cpp__('gfxSetWide(isWide2)');
		return isWide;
	}

	/**
	 * Deinitializes and frees the LCD framebuffers.
	 * 
	 * This function internally calls gspExit.
	 */
	@:native("gfxExit")
	public static function exit() {};
}