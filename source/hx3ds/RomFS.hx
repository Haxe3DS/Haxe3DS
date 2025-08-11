package hx3ds;

/**
 * RomFS driver.
 */
@:cppInclude("fstream") // For readFile
class RomFS {
	/**
	 * Wrapper for romfsMountSelf with the default "romfs" device name.
	 */
	@:native("romfsInit")
	public static function init():Void {};

	/**
	 * Reads a file from SDMC/ROMFS and gets the current read string from file.
	 * @param path The path to read from, include the `sdmc:/` or `romfs:/` file.
	 * @return Current content from file, "" if file was not found or file is 0 bytes.
	 */
	public static function readFile(path:String):String {
		var content:String = "";
		untyped __cpp__("std::ifstream file(path);
if (!file.is_open()) {
    return \"\";
}
std::string line;
while (std::getline(file, line)) {
    content += line + '\\n';
}
file.close()");
		return content;
	}

	/**
	 * Wrapper for romfsUnmount with the default "romfs" device name.
	 */
	@:native("romfsExit")
	public static function exit():Void {};
}
