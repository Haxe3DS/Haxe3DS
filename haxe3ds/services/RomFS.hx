package haxe3ds.services;

import haxe3ds.Types.Result;

/**
 * RomFS Driver, for Mounting, Unmounting, etc.
 */
@:cppInclude("3ds.h")
class RomFS {
	/**
	 * A function to mount the RomFS driver, upon doing so, this allows devs to use `romfs:/` extensions, accessing other files for reading only.
	 * @return Result to indicate whether an error has occurred or not.
	 */
	public static function init():Result {
		return untyped __cpp__('romfsInit()');
	}

	/**
	 * A function that unmounts the RomFS driver, it completely blocks you from accessing `romfs:/` for other files.
	 * @return Result to indicate whether an error has occurred or not.
	 */
	public static function exit():Result {
		return untyped __cpp__('romfsExit()');
	}
}