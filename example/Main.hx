import haxe3ds.HID;
import haxe3ds.APT;
import haxe3ds.Console;
import haxe3ds.GFX;

function main() {
	untyped __include__("3ds.h");

	GFX.initDefault();
	Console.init(GFX_TOP);
	trace("Hello, World!");

	while (APT.mainLoop()) {
		HID.scanInput();
		if (HID.keyPressed(Key.START)) {
			break;
		}
	}

	GFX.exit();
}