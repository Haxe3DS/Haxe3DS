import hx3ds.OS;
import hx3ds.AM;
import hx3ds.CFGU;
import hx3ds.PTMU;
import hx3ds.HID;
import hx3ds.Console;
import hx3ds.GFX;
import hx3ds.APT;

function main() {
	untyped __include__("3ds.h");
	
	GFX.initDefault();
	PTMU.init();
	CFGU.init();
	AM.init();
	Console.init(GFX_TOP);

	OS.setSpeedupEnable(APT.isNew3DS());

	trace('${ConsoleColor.textRed}Hello, ${ConsoleColor.textGreen}${ConsoleColor.borderWhite}World!${ConsoleColor.borderBlack}${ConsoleColor.textYhite}');
	trace('Press [START] to exit.');

	trace('Total Steps:     ${PTMU.getTotalSteps()}');
	trace('U Chargin?:      ${PTMU.isCharging()}');
	trace('Ur Shell Closy?: ${PTMU.isShellClosed()}');
	trace('U losin\' wait?:  ${PTMU.isWalking()}');

	if (CFGU.isUsing2DS()) {
		trace("Switch to a 3DS!");
	} else {
		trace("Hello smart usyer!");
	}

	trace('You have ${AM.getTicketCount()} titles! Amazing!!!');
	
	while (APT.mainLoop()) {
		HID.scanInput();
		if (HID.keyPressed(Key.START)) {
			break;
		}
	}
	
	AM.exit();
	CFGU.exit();
	PTMU.exit();
	GFX.exit();
}