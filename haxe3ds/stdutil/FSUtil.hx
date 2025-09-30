package haxe3ds.stdutil;

import cxx.std.FileSystem;

/**
 * Better File System Utility with extra functions for IO.
 */
@:cppFileCode("
#include <fstream>
#include <filesystem>
")
class FSUtil {
	/**
	 * Reads a file from SDMC/ROMFS and gets the current read string from file.
	 * @param path The path to read from, include the `sdmc:/`, `romfs:/`, or the save data partition if it's mounted.
	 * @return Current content from file, "" if file was not found or file is 0 bytes.
	 */
	public static function readFile(path:String):String {
		untyped __cpp__('
			using namespace std;
    		ifstream ifs(path);
		');

		return untyped __cpp__('istreambuf_iterator<char>{ifs}, {}');
	}

	/**
	 * Reads a whole directory and retrieves an array of file paths, working version of FileSystem.readDirectory();
	 * @param dir The directory path to read, you must include `sdmc:/` or `romfs:/` partition, or the save data partition if it's mounted.
	 * @param recursive Whetever or not you want it to be recursive, **OPTIONAL** defaults to false.
	 * @return The whole directory file and dir names read. (example: romfs:/hi.txt, romfs:/Cool File.ogg, romfs:/A Folder)
	 */
	public static function readDirectory(dir:String, recursive:Bool = false):Array<String> {
		var ret:Array<String> = [];
		untyped __cpp__('
			namespace fs = std::filesystem;
			if (recursive) {
				for (auto &&r : fs::recursive_directory_iterator(dir)) ret->push_back(r.path());
			} else {
				for (auto &&r : fs::directory_iterator(dir)) ret->push_back(r.path());
			}
		');
		return ret;
	}

	/**
	 * Checks if path provided is a file or not
	 * @param path Path to check file path, you must include `sdmc:/` or `romfs:/` partition, or the save data partition if it's mounted.
	 * @return true if it's a file, false if it's a dir or doesn't exist.
	 */
	public static function isFile(path:String):Bool {
		return untyped __cpp__("std::filesystem::is_regular_file(path)");
	}

	/**
	 * Checks if path provided is a directory or not
	 * @param path Path to check directory path, you must include `sdmc:/` or `romfs:/` partition, or the save data partition if it's mounted.
	 * @return true if it's a directory, false if it's a file or doesn't exist.
	 */
	public static function isDirectory(path:String):Bool {
		return untyped __cpp__("std::filesystem::is_directory(path)");
	}

	/**
	 * Checks if one of the files exists or not.
	 * @param path Path to check which directory or file it exists, you must include `sdmc:/` or `romfs:/` partition, or the save data partition if it's mounted.
	 * @return true if present and existing, false if isn't found.
	 */
	public static function exists(path:String):Bool {
		return FileSystem.exists(path);
	}

	/**
	 * Creates a new directory.
	 * @param path Path to create a new directory, you must include `sdmc:/` partition or the save data partition if it's mounted.
	 * @return true if successfully created directory, false if failed to create.
	 */
	public static function createDirectory(path:String):Bool {
		return untyped __cpp__('std::filesystem::create_directories(path)');
	}

	/**
	 * Saves a file to path provided.
	 * @param path Path to save from, must include the `sdmc:/` partition path or the extdata partition path.
	 * @param content Contents to store in the file.
	 * @return true if successfully saved, false if path doesn't exist.
	 */
	public static function saveFile(path:String, content:String):Bool {
		untyped __cpp__('
		    std::ofstream file(path);
    	    if (!file.is_open()) {
    	        return false;
    	    }
    
    	    file << content;
    	    file.close()
		');
		return true;
	}

	/**
	 * Copies a file to their desired location, NOTE: Copying only works on SDMC or in SAVE DATA!
	 * @param fromPath Path to the file that's located at the partition.
	 * @param toPath Path to copy from the path.
	 * @return `true` if successfully copied, `false` if failed to copy.
	 */
	public static function copyFile(fromPath:String, toPath:String):Bool {
		return untyped __cpp__('std::filesystem::copy_file(fromPath, toPath)');
	}
}