#include "haxe_Log.h"

#include <deque>
#include <functional>
#include <iostream>
#include <memory>
#include <string>
#include "cxx_DynamicToString.h"
#include "haxe_NativeStackTrace.h"
#include "haxe_PosInfos.h"
#include "Std.h"

using namespace std::string_literals;

std::function<void(haxe::DynamicToString, std::optional<std::shared_ptr<haxe::PosInfos>>)> haxe::Log::trace = [](haxe::DynamicToString v, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt) mutable {
	HCXX_STACK_METHOD("C:/Users/nael/Downloads/3DSHaxe/reflaxe_HaxeLibCTRU/.haxelib/reflaxe,cpp/git/src/haxe/Log.cross.hx"s, 25, 99, "haxe.Log"s, "trace.<unnamed>"s);
	std::string str = haxe::Log::formatOutput(v, infos);

	std::cout << Std::string(str) << std::endl;
};

std::string haxe::Log::formatOutput(std::string v, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	HCXX_STACK_METHOD("C:/Users/nael/Downloads/3DSHaxe/reflaxe_HaxeLibCTRU/.haxelib/reflaxe,cpp/git/src/haxe/Log.cross.hx"s, 8, 2, "haxe.Log"s, "formatOutput"s);

	HCXX_LINE(9);
	if(!infos.has_value()) {
		HCXX_LINE(10);
		return v;
	};

	HCXX_LINE(13);
	std::string pstr = infos.value_or(nullptr)->fileName + ":"s + std::to_string(infos.value_or(nullptr)->lineNumber);
	HCXX_LINE(15);
	std::string extra = ""s;

	HCXX_LINE(16);
	if(infos.value_or(nullptr)->customParams.has_value()) {
		HCXX_LINE(17);
		int _g = 0;
		HCXX_LINE(17);
		std::optional<std::shared_ptr<std::deque<haxe::DynamicToString>>> _g1 = infos.value_or(nullptr)->customParams;

		HCXX_LINE(17);
		while(_g < (int)(_g1.value_or(nullptr)->size())) {
			HCXX_LINE(17);
			haxe::DynamicToString v2 = (*_g1.value())[_g];

			HCXX_LINE(17);
			++_g;
			HCXX_LINE(18);
			extra += ", "s + v2;
		};
	};

	HCXX_LINE(22);
	return pstr + ": "s + v + extra;
}
