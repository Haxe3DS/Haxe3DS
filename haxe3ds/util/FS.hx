package haxe3ds.util;

import cxx.std.FileSystem;

@:cppInclude("fstream") // For readFile
@:cppInclude("filesystem") // For readFile
class FS {
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
	 * @param recursive Whetever or not you want it to be recursive, **OPTIONAL** defaults to false.
	 * @return The whole directory file and dir names read. (example: ~~romfs:/~~hi.txt, ~~romfs:/~~Cool File.ogg, ~~romfs:/~~A Folder)
	 */
	public static function readDirectory(dir:String, recursive:Bool = false):Array<String> {
		var ret:Array<String> = [];
		untyped __cpp__('
			namespace fs = std::filesystem;
			if (recursive) {
				for (auto &&r : fs::recursive_directory_iterator(dir)) ret->push_back(r.path().filename());
			} else {
				for (auto &&r : fs::directory_iterator(dir)) ret->push_back(r.path().filename());
			}
		');
		return ret;
	}

	/**
	 * Checks if path provided is a file or not
	 * @param path Path to check file path, you must include `sdmc:/` or `romfs:/` partition.
	 * @return true if it's a file, false if it's a dir or doesn't exist.
	 */
	public static function isFile(path:String):Bool {
		return untyped __cpp__("std::filesystem::is_regular_file(path)");
	}

	/**
	 * Checks if path provided is a directory or not
	 * @param path Path to check directory path, you must include `sdmc:/` or `romfs:/` partition.
	 * @return true if it's a directory, false if it's a file or doesn't exist.
	 */
	public static function isDirectory(path:String):Bool {
		return untyped __cpp__("std::filesystem::is_directory(path)");
	}

	/**
	 * Checks if one of the files exists or not.
	 * @param path Path to check which directory or file it exists, you must include `sdmc:/` or `romfs:/` partition.
	 * @return true if present and existing, false if isn't found.
	 */
	public static function exists(path:String):Bool {
		return FileSystem.exists(path);
	}

	/**
	 * Creates a new directory, `sdmc:/` is included by default and cannot be changed.
	 * @param path Path to create a new directory, don't include `sdmc:/`
	 * @return true if successfully created directory, false if failed to create.
	 */
	public static function createDirectory(path:String):Bool {
		return untyped __cpp__('std::filesystem::create_directory("sdmc:/" + path)');
	}

	/**
	 * Saves a file to path provided.
	 * @param path Path to save from.
	 * @param content Contents to store in the file.
	 * @return true if successfully saved, false if path doesn't exist.
	 */
	public static function saveFile(path:String, content:String):Bool {
		untyped __cpp__('
		    std::ofstream file("sdmc:/" + path);
    	    if (!file.is_open()) {
    	        return false;
    	    }
    
    	    file << content;
    	    file.close()
		');
		return true;
	}
}