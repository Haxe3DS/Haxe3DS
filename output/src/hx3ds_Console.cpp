#include "hx3ds_Console.h"

#include <memory>
#include <string>
#include "haxe_NativeStackTrace.h"

using namespace std::string_literals;

void hx3ds::Console::consoleInit(std::shared_ptr<hx3ds::GfxScreen_t> screen, std::optional<std::string>) {
	HCXX_STACK_METHOD("source/hx3ds/Console.hx"s, 41, 2, "hx3ds.Console"s, "consoleInit"s);


}

void hx3ds::Console::consoleClear() {
	HCXX_STACK_METHOD("source/hx3ds/Console.hx"s, 47, 2, "hx3ds.Console"s, "consoleClear"s);


}