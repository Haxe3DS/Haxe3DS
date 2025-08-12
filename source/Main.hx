import hx3ds.CFGU;
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

	trace('Cur Vol: ${HID.getSoundVolume()}');
	
	trace('You have ${News.getTotalNotifications()} notifications!');
	trace('And the file in hi.txt says:\n${RomFS.readFile("romfs:/hi.txt")}');

	trace('Your language: ${CFGU.getSystemLanguage()}');

	trace('Press [A] to show Accel!');
	trace('Press [B] to show Gyro!');
	
	while (APT.mainLoop()) {
		HID.scanInput();
		if (HID.keyPressed(Key.START)) {
			break;
		} else if (HID.keyPressed(Key.A)) {
			Console.clear();

			var a = HID.accelRead();
			trace('Acc X: ${a.x}');
			trace('Acc Y: ${a.y}');
			trace('Acc Z: ${a.z}');
		} else if (HID.keyPressed(Key.B)) {
			Console.clear();
			
			HID.enableGyroscope();
			var a = HID.gyroRead();
			trace('Roll  X: ${a.x}');
			trace('Pitch Y: ${a.y}');
			trace('Yaw   Z: ${a.z}');
		}
	}
		
	RomFS.exit();
	News.exit();
	GFX.exit();
}