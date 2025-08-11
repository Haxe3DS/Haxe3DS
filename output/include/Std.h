#pragma once

#include <limits>
#include <memory>
#include <optional>
#include <string>
#include "_AnonUtils.h"
#include "cxx_DynamicToString.h"
#include "haxe_NativeStackTrace.h"

class Std {
public:
	static std::string string(haxe::DynamicToString s) {
		HCXX_STACK_METHOD(std::string("C:/Users/nael/Downloads/3DSHaxe/reflaxe_HaxeLibCTRU/.haxelib/reflaxe,cpp/git/src/Std.cross.hx"), 45, 2, std::string("Std"), std::string("string"));

		HCXX_LINE(46);
		return s;
	}
	static std::optional<int> parseInt(std::string x) {
		HCXX_STACK_METHOD(std::string("C:/Users/nael/Downloads/3DSHaxe/reflaxe_HaxeLibCTRU/.haxelib/reflaxe,cpp/git/src/Std.cross.hx"), 53, 2, std::string("Std"), std::string("parseInt"));

		HCXX_LINE(57);
		try { return std::stoi(x); } catch(...) {};

		HCXX_LINE(59);
		return std::nullopt;
	}
	static double parseFloat(std::string x) {
		HCXX_STACK_METHOD(std::string("C:/Users/nael/Downloads/3DSHaxe/reflaxe_HaxeLibCTRU/.haxelib/reflaxe,cpp/git/src/Std.cross.hx"), 62, 2, std::string("Std"), std::string("parseFloat"));

		HCXX_LINE(66);
		try { return std::stof(x); } catch(...) {};

		HCXX_LINE(68);
		return std::numeric_limits<double>::quiet_NaN();
	}
};

