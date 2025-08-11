#pragma once

#include <memory>
#include <optional>
#include <string>

namespace hx3ds {

class GfxScreen_t {
public:
	int index;

	GfxScreen_t() {
		index = -1;
	}

	static std::shared_ptr<hx3ds::GfxScreen_t> GFX_TOP() {
		GfxScreen_t result;
		result.index = 0;
		return std::make_shared<hx3ds::GfxScreen_t>(result);
	}

	static std::shared_ptr<hx3ds::GfxScreen_t> GFX_BOTTOM() {
		GfxScreen_t result;
		result.index = 1;
		return std::make_shared<hx3ds::GfxScreen_t>(result);
	}

	std::string toString() {
		switch(index) {
			case 0: {
				return std::string("GFX_TOP");
			}
			case 1: {
				return std::string("GFX_BOTTOM");
			}
			default: return "";
		}
		return "";
	}

	operator bool() const {
		return true;
	}
};
}


namespace hx3ds {

class Console {
public:
	static void consoleInit(std::shared_ptr<hx3ds::GfxScreen_t> screen, std::optional<std::string>);
	static void consoleClear();
};

}
