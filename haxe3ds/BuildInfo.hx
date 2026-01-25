package haxe3ds;

import sys.io.File;

/**
 * Haxe3DS Build Info (Requires RomFS to be Initialized!)
 * @since 1.7.0
 */
class BuildInfo {
	/**
	 * The *Current Build* Version for this Application, returns -1 if File is missing or has an invalid number, unless returns Actual Build Version.
	 * 
	 * This file is stored in RomFS, so it's required to call `RomFS.init` to access that file.
	 */
	public static var BUILD(get, null):Int;
	static function get_BUILD():Int {
		try {
			return Std.parseInt(File.getContent("romfs:/.haxe3ds/.build")) ?? -1;
		} catch(e) {
			return -1;
		}
	}

	/**
	 * The *Current Haxe3DS Version* for this Application (or the library), returns "?" if File is missing or has an invalid number, unless returns Actual Haxe3DS Version.
	 * 
	 * This file is stored in RomFS, so it's required to call `RomFS.init` to access that file.
	 */
	public static var VERSION(get, null):String;
	static function get_VERSION():String {
		try {
			return File.getContent("romfs:/.haxe3ds/.version");
		} catch(e) {
			return "?";
		}
	}
}