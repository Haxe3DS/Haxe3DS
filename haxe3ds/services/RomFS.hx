package haxe3ds.services;

/**
 * RomFS driver, along with many other IO tools.
 */
class RomFS {
	/**
	 * Wrapper for romfsMountSelf with the default "romfs" device name.
	 */
	@:native("romfsInit")
	public static function init() {};

	/**
	 * Wrapper for romfsUnmount with the default "romfs" device name.
	 */
	@:native("romfsExit")
	public static function exit() {};
}
