#include "hx3ds_RomFS.h"

#include <memory>
#include <string>
#include "fstream"
#include "haxe_NativeStackTrace.h"

using namespace std::string_literals;

void hx3ds::RomFS::romfsInit() {
	HCXX_STACK_METHOD("source/hx3ds/RomFS.hx"s, 12, 2, "hx3ds.RomFS"s, "romfsInit"s);


}

std::string hx3ds::RomFS::readFile(std::string path) {
	HCXX_STACK_METHOD("source/hx3ds/RomFS.hx"s, 19, 2, "hx3ds.RomFS"s, "readFile"s);

	HCXX_LINE(20);
	std::string content = ""s;

	HCXX_LINE(21);
	std::ifstream file(path);
	if (!file.is_open()) {
	    return "";
	}
	std::string line;
	while (std::getline(file, line)) {
	    content += line + '\n';
	}
	file.close();

	HCXX_LINE(30);
	return content;
}

void hx3ds::RomFS::romfsExit() {
	HCXX_STACK_METHOD("source/hx3ds/RomFS.hx"s, 37, 2, "hx3ds.RomFS"s, "romfsExit"s);


}