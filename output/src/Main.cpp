#include "Main.h"

#include <iostream>
#include <memory>
#include <string>
#include "3ds.h"
#include "_AnonStructs.h"
#include "cxx_DynamicToString.h"
#include "haxe_Exception.h"
#include "haxe_Log.h"
#include "haxe_NativeStackTrace.h"
#include "hx3ds_APT.h"
#include "hx3ds_Console.h"
#include "hx3ds_GFX.h"
#include "hx3ds_HID.h"
#include "hx3ds_News.h"
#include "hx3ds_RomFS.h"
#include "Std.h"

using namespace std::string_literals;

void _Main::Main_Fields_::main() {
	HCXX_STACK_METHOD("source/Main.hx"s, 9, 1, "_Main.Main_Fields_"s, "main"s);

	HCXX_LINE(10);
	HCXX_LINE(12);
	gfxInitDefault();
	HCXX_LINE(13);
	newsInit();
	HCXX_LINE(14);
	romfsInit();
	HCXX_LINE(16);
	consoleInit(GFX_TOP, NULL);

	HCXX_LINE(18);
	try {
		HCXX_LINE(19);
		haxe::Log::trace("You have "s + Std::string(hx3ds::News::getTotalNotifications()) + " notifications!"s, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "source/Main.hx"s, 19, "main"s));
		HCXX_LINE(20);
		haxe::Log::trace("And the file in hi.txt says:\n"s + hx3ds::RomFS::readFile("romfs:/hi.txt"s), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "source/Main.hx"s, 20, "main"s));
		HCXX_LINE(22);
		std::cout << "source/Main.hx:22: Press [A] to throw an error!"s << std::endl;

		HCXX_LINE(24);
		while(aptMainLoop()) {
			HCXX_LINE(25);
			hidScanInput();

			HCXX_LINE(26);
			if(hx3ds::HID::keyPressed(KEY_START)) {
				HCXX_LINE(27);
				break;
			} else if(hx3ds::HID::keyPressed(KEY_A)) {
				HCXX_LINE(29);
				throw haxe::Exception("test haxe exception"s, std::nullopt, std::nullopt);
			};
		};
	} catch(haxe::Exception& e) {
		HCXX_LINE(33);
		consoleClear();
		HCXX_LINE(34);
		std::cout << "<<< EXCEPTION OCCURRED! >>>\n"s << std::endl;

		HCXX_LINE(35);
		haxe::DynamicToString v = e.details();

		HCXX_LINE(35);
		std::cout << Std::string(v) << std::endl;
		HCXX_LINE(36);
		std::cout << "Press [A] to close."s << std::endl;

		HCXX_LINE(38);
		while(aptMainLoop()) {
			HCXX_LINE(39);
			hidScanInput();

			HCXX_LINE(40);
			if(hx3ds::HID::keyPressed(KEY_A)) {
				HCXX_LINE(41);
				break;
			};
		};
	};

	HCXX_LINE(46);
	romfsExit();
	HCXX_LINE(47);
	newsExit();
	HCXX_LINE(48);
	gfxExit();
}