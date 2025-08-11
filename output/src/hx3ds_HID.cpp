#include "hx3ds_HID.h"

#include <memory>
#include <string>
#include "3ds.h"
#include "_AnonStructs.h"
#include "haxe_NativeStackTrace.h"

using namespace std::string_literals;

void hx3ds::HID::hidScanInput() {
	HCXX_STACK_METHOD("source/hx3ds/HID.hx"s, 154, 2, "hx3ds.HID"s, "hidScanInput"s);


}

bool hx3ds::HID::keyPressed(uint32_t key) {
	HCXX_STACK_METHOD("source/hx3ds/HID.hx"s, 161, 2, "hx3ds.HID"s, "keyPressed"s);

	HCXX_LINE(161);
	return hidKeysDown() & key;
}

bool hx3ds::HID::keyHeld(uint32_t key) {
	HCXX_STACK_METHOD("source/hx3ds/HID.hx"s, 168, 2, "hx3ds.HID"s, "keyHeld"s);

	HCXX_LINE(168);
	return hidKeysHeld() & key;
}

bool hx3ds::HID::keyUp(uint32_t key) {
	HCXX_STACK_METHOD("source/hx3ds/HID.hx"s, 175, 2, "hx3ds.HID"s, "keyUp"s);

	HCXX_LINE(175);
	return hidKeysUp() & key;
}

std::shared_ptr<hx3ds::CirclePosition> hx3ds::HID::circlePadRead() {
	HCXX_STACK_METHOD("source/hx3ds/HID.hx"s, 181, 2, "hx3ds.HID"s, "circlePadRead"s);

	HCXX_LINE(182);
	std::shared_ptr<hx3ds::CirclePosition> pos = haxe::shared_anon<hx3ds::CirclePosition>(0, 0);

	HCXX_LINE(183);
	circlePosition temp;
	hidCircleRead(&temp);
	pos->dx = temp.dx;
	pos->dy = temp.dy;

	HCXX_LINE(187);
	return pos;
}

std::shared_ptr<hx3ds::TouchPosition> hx3ds::HID::touchPadRead() {
	HCXX_STACK_METHOD("source/hx3ds/HID.hx"s, 194, 2, "hx3ds.HID"s, "touchPadRead"s);

	HCXX_LINE(195);
	std::shared_ptr<hx3ds::TouchPosition> pos = haxe::shared_anon<hx3ds::TouchPosition>(0, 0);

	HCXX_LINE(196);
	touchPosition temp;
	hidTouchRead(&temp);
	pos->px = temp.px;
	pos->py = temp.py;

	HCXX_LINE(200);
	return pos;
}