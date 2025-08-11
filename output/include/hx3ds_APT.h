#pragma once

namespace hx3ds {

class APT {
public:
	static void aptInit();
	static void aptExit();
	static bool isNew3DS();
	static bool aptIsHomeAllowed();
	static void aptSetHomeAllowed(bool allowed);
	static void aptJumpToHomeMenu();
	static bool aptCheckHomePressRejected();
	static bool aptMainLoop();
};

}
