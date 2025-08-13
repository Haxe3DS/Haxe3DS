import hx3ds.PTMU;
import hx3ds.HID;
import hx3ds.Console;
import hx3ds.GFX;
import hx3ds.APT;

function main() {
	untyped __include__("3ds.h");
	
	GFX.initDefault();
	PTMU.init();
	Console.init(GFX_TOP);

	trace('${ConsoleColor.textRed}Hello, ${ConsoleColor.textGreen}${ConsoleColor.borderWhite}World!${ConsoleColor.borderBlack}${ConsoleColor.textYhite}');
	trace('Press [START] to exit.');

	trace('Total Steps:     ${PTMU.getTotalSteps()}');
	trace('U Chargin?:      ${PTMU.isCharging()}');
	trace('Ur Shell Closy?: ${PTMU.isShellClosed()}');
	trace('U losin\' wait?:  ${PTMU.isWalking()}');
	
	while (APT.mainLoop()) {
		HID.scanInput();
		if (HID.keyPressed(Key.START)) {
			break;
		}
	}
		
	PTMU.exit();
	GFX.exit();
}