#include "haxe_Exception.h"

#include <memory>
#include <string>
#include "haxe_CallStack.h"
#include "haxe_NativeStackTrace.h"
#include "Std.h"

using namespace std::string_literals;

haxe::Exception::Exception(std::string message2, std::optional<haxe::Exception> previous2, std::optional<std::any> native2):
	std::exception(), _order_id(generate_order_id())
{
	HCXX_STACK_METHOD("C:/Users/nael/Downloads/3DSHaxe/reflaxe_HaxeLibCTRU/.haxelib/reflaxe,cpp/git/src/haxe/Exception.cross.hx"s, 51, 2, "haxe.Exception"s, "Exception"s);

	HCXX_LINE(52);
	HCXX_LINE(54);
	this->_message = message2;

	HCXX_LINE(55);
	std::optional<std::shared_ptr<haxe::Exception>> tempRight;

	HCXX_LINE(55);
	if(previous2.has_value()) {
		HCXX_LINE(55);
		tempRight = std::make_shared<haxe::Exception>(previous2.value());
	} else {
		HCXX_LINE(55);
		tempRight = std::nullopt;
	};

	HCXX_LINE(55);
	this->_previous = tempRight;
	HCXX_LINE(57);
	this->_stack = haxe::NativeStackTrace::toHaxe(haxe::NativeStackTrace::callStack(), 0);
}

std::string haxe::Exception::get_message() {
	HCXX_STACK_METHOD("C:/Users/nael/Downloads/3DSHaxe/reflaxe_HaxeLibCTRU/.haxelib/reflaxe,cpp/git/src/haxe/Exception.cross.hx"s, 9, 2, "haxe.Exception"s, "get_message"s);

	HCXX_LINE(10);
	return this->_message;
}

std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> haxe::Exception::get_stack() {
	HCXX_STACK_METHOD("C:/Users/nael/Downloads/3DSHaxe/reflaxe_HaxeLibCTRU/.haxelib/reflaxe,cpp/git/src/haxe/Exception.cross.hx"s, 14, 2, "haxe.Exception"s, "get_stack"s);

	HCXX_LINE(16);
	return this->_stack;
}

std::optional<haxe::Exception> haxe::Exception::get_previous() {
	HCXX_STACK_METHOD("C:/Users/nael/Downloads/3DSHaxe/reflaxe_HaxeLibCTRU/.haxelib/reflaxe,cpp/git/src/haxe/Exception.cross.hx"s, 24, 2, "haxe.Exception"s, "get_previous"s);

	auto v = this->_previous;
	HCXX_LINE(25);
	return v.has_value() ? (std::optional<haxe::Exception>)(*v.value_or(nullptr)) : std::nullopt;
}

std::any haxe::Exception::get_native() {
	HCXX_STACK_METHOD("C:/Users/nael/Downloads/3DSHaxe/reflaxe_HaxeLibCTRU/.haxelib/reflaxe,cpp/git/src/haxe/Exception.cross.hx"s, 29, 2, "haxe.Exception"s, "get_native"s);

	HCXX_LINE(30);
	return 0;
}

std::any haxe::Exception::unwrap() {
	HCXX_STACK_METHOD("C:/Users/nael/Downloads/3DSHaxe/reflaxe_HaxeLibCTRU/.haxelib/reflaxe,cpp/git/src/haxe/Exception.cross.hx"s, 61, 2, "haxe.Exception"s, "unwrap"s);

	HCXX_LINE(62);
	return 0;
}

std::string haxe::Exception::toString() {
	HCXX_STACK_METHOD("C:/Users/nael/Downloads/3DSHaxe/reflaxe_HaxeLibCTRU/.haxelib/reflaxe,cpp/git/src/haxe/Exception.cross.hx"s, 65, 2, "haxe.Exception"s, "toString"s);

	HCXX_LINE(66);
	return "Error: "s + this->get_message();
}

std::string haxe::Exception::details() {
	HCXX_STACK_METHOD("C:/Users/nael/Downloads/3DSHaxe/reflaxe_HaxeLibCTRU/.haxelib/reflaxe,cpp/git/src/haxe/Exception.cross.hx"s, 69, 2, "haxe.Exception"s, "details"s);

	HCXX_LINE(70);
	return this->toString() + "\n"s + haxe::_CallStack::CallStack_Impl_::toString(this->get_stack());
}

haxe::Exception haxe::Exception::caught(std::any value) {
	HCXX_STACK_METHOD("C:/Users/nael/Downloads/3DSHaxe/reflaxe_HaxeLibCTRU/.haxelib/reflaxe,cpp/git/src/haxe/Exception.cross.hx"s, 35, 2, "haxe.Exception"s, "caught"s);

	HCXX_LINE(36);
	std::string tempString = "<Any("s + Std::string(value.type().name()) + ")>"s;

	HCXX_LINE(36);
	return haxe::Exception(tempString, std::nullopt, std::nullopt);
}

std::any haxe::Exception::thrown(std::any value) {
	HCXX_STACK_METHOD("C:/Users/nael/Downloads/3DSHaxe/reflaxe_HaxeLibCTRU/.haxelib/reflaxe,cpp/git/src/haxe/Exception.cross.hx"s, 39, 2, "haxe.Exception"s, "thrown"s);

	HCXX_LINE(40);
	return 0;
}
