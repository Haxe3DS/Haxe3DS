/**
 * File Manager handling for 3DS's SDMC.
 * 
 * Controls:
 * 		   A - Open File
 * 		   B - Go back to root of directory.
 *   DPAD UP - Decrement Index
 * DPAD Down - Increment Index
 * 		   Y - Close File (only if read)
 * 	   START - Exit
 */
import haxe3ds.util.FSUtil as FS;
import haxe3ds.services.HID;
import haxe3ds.services.APT;
import haxe3ds.Console;
import haxe3ds.services.GFX;

var path:String = "sdmc:/";
var contents:Array<String> = FS.readDirectory(path);
var index:Int = 0;

function printDirectories() {
	index = index >= contents.length ? contents.length-1 : index < 0 ? 0 : index;

	Console.clear();
	for (i in -12+index...12+index) {
		if (i < 0) {
			Sys.println("");
			continue;
		} else if (i >= contents.length) {
			break;
		}

		Sys.println('${i == index ? "> " : "  "}${contents[i]}${i == index ? " <" : ""}');
	}
}

function main() {
	untyped __include__("3ds.h");
	
	GFX.initDefault();
	Console.init(GFX_TOP);
	printDirectories();

	while (APT.mainLoop()) {
		HID.scanInput();
		if (HID.keyPressed(Key.START)) {
			break;
		}

		if (HID.keyPressed(Key.DUP)) {
			index--;
			printDirectories();
		} else if (HID.keyPressed(Key.DDOWN)) {
			index++;
			printDirectories();
		} else if (HID.keyPressed(Key.A)) {
			final f:String = path.substr(6, -1) + contents[index];
			if (!FS.exists(f)) {
				Sys.println(f);
				continue;
			}

			if (FS.isFile(f)) {
				Console.clear();
				Sys.println(ConsoleColor.borderBlue + FS.readFile(path + f));
				Sys.println(ConsoleColor.borderBlack + "Press Y to quit reading.");

				while (APT.mainLoop()) {
					HID.scanInput();
					if (HID.keyPressed(Key.Y)) break;
				}
			} else {
				path += f + "/";
				contents = FS.readDirectory(path);
			}

			printDirectories();
		} else if (HID.keyPressed(Key.B)) {
			path = "sdmc:/";
			contents = FS.readDirectory(path);
			printDirectories();
		} 
	}

	GFX.exit();
}