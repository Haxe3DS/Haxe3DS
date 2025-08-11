#pragma once

#include "_AnonStructs.h"
#include <cstdint>
#include <memory>

namespace hx3ds {

// { dx: Int, dy: Int }
struct CirclePosition {

	// default constructor
	CirclePosition() {}

	// auto-construct from any object's fields
	template<typename T>
	CirclePosition(T o):
		dx(haxe::unwrap(o).dx),
		dy(haxe::unwrap(o).dy)
	{}

	// construct fields directly
	static CirclePosition make(int dx, int dy) {
		CirclePosition result;
		result.dx = dx;
		result.dy = dy;
		return result;
	}

	// fields
	int dx;
	int dy;
};

}

namespace hx3ds {

// { px: Int, py: Int }
struct TouchPosition {

	// default constructor
	TouchPosition() {}

	// auto-construct from any object's fields
	template<typename T>
	TouchPosition(T o):
		px(haxe::unwrap(o).px),
		py(haxe::unwrap(o).py)
	{}

	// construct fields directly
	static TouchPosition make(int px, int py) {
		TouchPosition result;
		result.px = px;
		result.py = py;
		return result;
	}

	// fields
	int px;
	int py;
};

}

namespace hx3ds {

class HID {
public:
	static void hidScanInput();
	static bool keyPressed(uint32_t key);
	static bool keyHeld(uint32_t key);
	static bool keyUp(uint32_t key);
	static std::shared_ptr<hx3ds::CirclePosition> circlePadRead();
	static std::shared_ptr<hx3ds::TouchPosition> touchPadRead();
};

}
