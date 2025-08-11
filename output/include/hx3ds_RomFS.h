#pragma once

#include <string>

namespace hx3ds {

class RomFS {
public:
	static void romfsInit();
	static std::string readFile(std::string path);
	static void romfsExit();
};

}
