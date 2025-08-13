import hx3ds.HID;
import hx3ds.Console;
import hx3ds.GFX;
import hx3ds.APT;

function main() {
	untyped __include__("3ds.h");
	
	GFX.initDefault();
	Console.init(GFX_TOP);

	trace('${ConsoleColor.red}Hello, ${ConsoleColor.green}World!${ConsoleColor.white}');
	trace('Press [START] to exit.');
	
	while (APT.mainLoop()) {
		HID.scanInput();
		if (HID.keyPressed(Key.START)) {
			break;
		}
	}
		
	GFX.exit();
}