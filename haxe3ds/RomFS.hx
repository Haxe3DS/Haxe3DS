package haxe3ds;

/**
 * RomFS driver.
 */
@:cppInclude("fstream") // For readFile
@:cppInclude("filesystem") // For readDirectory
class RomFS {
	/**
	 * Wrapper for romfsMountSelf with the default "romfs" device name.
	 */
	@:native("romfsInit")
	public static function init():Void {};

	/**
	 * Reads a file from SDMC/ROMFS and gets the current read string from file.
	 * @param path The path to read from, include the `sdmc:/` or `romfs:/` partition.
	 * @return Current content from file, "" if file was not found or file is 0 bytes.
	 */
	public static function readFile(path:String):String {
		var content:String = "";
		untyped __cpp__("
		std::ifstream file(path);
		if (!file.is_open()) return \"\";

		std::string line;
		while (std::getline(file, line)) content += line + '\\n';

		file.close()
		");
		return content;
	}

	/**
	 * Reads a whole directory, working version of FileSystem.readDirectory();
	 * @param dir The directory path to read, you must include `sdmc:/` or `romfs:/` partition.
	 * @return The whole directory file names read. (example: ~~romfs:/~~hi.txt, ~~romfs:/~~Cool File.ogg)
	 */
	public static function readDirectory(dir:String):Array<String> {
		var ret:Array<String> = [];
		untyped __cpp__('
		for (auto &&r : std::filesystem::directory_iterator(dir)) {
			ret->push_back(r.path().filename());
		}
		');
		return ret;
	}

	/**
	 * Wrapper for romfsUnmount with the default "romfs" device name.
	 */
	@:native("romfsExit")
	public static function exit():Void {};
}
