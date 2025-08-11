import haxe.Exception;
import hx3ds.RomFS;
import hx3ds.News;
import hx3ds.HID;
import hx3ds.Console;
import hx3ds.GFX;
import hx3ds.APT;

/**
 * this is like a really example code i guess
 */

function main() {
	untyped __include__("3ds.h");
	
	GFX.initDefault();
	News.init();
	RomFS.init();

	Console.init(GFX_TOP);
	
	try {
		trace('You have ${News.getTotalNotifications()} notifications!');
		trace('And the file in hi.txt says:\n${RomFS.readFile("romfs:/hi.txt")}');

		trace('Press [A] to throw an error!');
		
		while (APT.mainLoop()) {
			HID.scanInput();
			if (HID.keyPressed(Key.START)) {
				break;
			} else if (HID.keyPressed(Key.A)) {
				throw new Exception("test haxe exception");
			}
		}
	} catch(e:Exception) {
		Console.clear();
		Sys.println("<<< EXCEPTION OCCURRED! >>>\n");
		Sys.println(e.details());
		Sys.println("Press [A] to close.");

		while (APT.mainLoop()) {
			HID.scanInput();
			if (HID.keyPressed(Key.A)) {
				break;
			}
		}
	}
		
	RomFS.exit();
	News.exit();
	GFX.exit();
}