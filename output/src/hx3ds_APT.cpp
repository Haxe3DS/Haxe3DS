#include "hx3ds_APT.h"

#include <memory>
#include <string>
#include "3ds.h"
#include "haxe_NativeStackTrace.h"

using namespace std::string_literals;

void hx3ds::APT::aptInit() {
	HCXX_STACK_METHOD("source/hx3ds/APT.hx"s, 12, 2, "hx3ds.APT"s, "aptInit"s);


}

void hx3ds::APT::aptExit() {
	HCXX_STACK_METHOD("source/hx3ds/APT.hx"s, 18, 2, "hx3ds.APT"s, "aptExit"s);


}

bool hx3ds::APT::isNew3DS() {
	HCXX_STACK_METHOD("source/hx3ds/APT.hx"s, 24, 2, "hx3ds.APT"s, "isNew3DS"s);

	HCXX_LINE(25);
	bool check = false;

	HCXX_LINE(26);
	APT_CheckNew3DS(&check);;

	HCXX_LINE(27);
	return check;
}

bool hx3ds::APT::aptIsHomeAllowed() {
	HCXX_STACK_METHOD("source/hx3ds/APT.hx"s, 34, 2, "hx3ds.APT"s, "aptIsHomeAllowed"s);

	HCXX_LINE(34);
	return false;
}

void hx3ds::APT::aptSetHomeAllowed(bool allowed) {
	HCXX_STACK_METHOD("source/hx3ds/APT.hx"s, 41, 2, "hx3ds.APT"s, "aptSetHomeAllowed"s);


}

void hx3ds::APT::aptJumpToHomeMenu() {
	HCXX_STACK_METHOD("source/hx3ds/APT.hx"s, 47, 2, "hx3ds.APT"s, "aptJumpToHomeMenu"s);


}

bool hx3ds::APT::aptCheckHomePressRejected() {
	HCXX_STACK_METHOD("source/hx3ds/APT.hx"s, 53, 2, "hx3ds.APT"s, "aptCheckHomePressRejected"s);

	HCXX_LINE(53);
	return false;
}

bool hx3ds::APT::aptMainLoop() {
	HCXX_STACK_METHOD("source/hx3ds/APT.hx"s, 60, 2, "hx3ds.APT"s, "aptMainLoop"s);

	HCXX_LINE(60);
	return false;
}