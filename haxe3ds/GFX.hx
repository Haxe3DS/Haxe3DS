package haxe3ds;

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
	public static function initDefault():Void {
		Error.setup(TEXT, Default);
	};

	/**
	 * Enables or disables the 3D stereoscopic effect on the top screen.
	 * 
	 * #### Note
	 * Stereoscopic 3D is disabled by default.
	 * 
	 * @param enable Pass true to enable, false to disable.
	 */
	@:native("gfxSet3D")
	public static function set3D(enable:Bool):Void {};

	/**
	 * Retrieves the status of the 3D stereoscopic effect on the top screen.
	 * @return true if 3D enabled, false otherwise.
	 */
	@:native("gfxIs3D")
	public static function is3D():Bool return false;

	/**
	 * Retrieves the status of the 800px (double-height) high resolution display mode of the top screen.
	 * @return true if wide mode enabled, false otherwise.
	 */
	@:native("gfxIsWide")
	public static function isWide():Bool return false;

	/**
	 * Enables or disables the 800px (double-height) high resolution display mode of the top screen.
	 * 
	 * #### Note
	 * Wide mode is disabled by default.
	 * 
	 * Wide and stereoscopic 3D modes are mutually exclusive.
	 * 
	 * In wide mode pixels are not square, since scanlines are half as tall as they normally are.
	 * 
	 * #### Warning
	 * Wide mode does not work on Old 2DS consoles (however it does work on New 2DS XL consoles).
	 * 
	 * @param enable Pass true to enable, false to disable.
	 */
	@:native("gfxSetWide")
	public static function setWide(enable:Bool):Void {};

	/**
	 * Deinitializes and frees the LCD framebuffers.
	 * 
	 * This function internally calls gspExit.
	 */
	@:native("gfxExit")
	public static function exit():Void {};
}