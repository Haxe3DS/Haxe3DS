#include "haxe_CallStack.h"

#include <deque>
#include <memory>
#include <string>
#include "haxe_NativeStackTrace.h"
#include "Std.h"
#include "StringBuf.h"

using namespace std::string_literals;

std::string haxe::_CallStack::CallStack_Impl_::toString(std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> stack) {
	HCXX_STACK_METHOD("C:\\HaxeToolkit\\haxe\\std/haxe/CallStack.hx"s, 71, 2, "haxe._CallStack.CallStack_Impl_"s, "toString"s);

	HCXX_LINE(72);
	std::shared_ptr<StringBuf> b = std::make_shared<StringBuf>();
	HCXX_LINE(73);
	int _g = 0;
	HCXX_LINE(73);
	std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> _g1 = stack;

	HCXX_LINE(73);
	while(_g < (int)(_g1->size())) {
		HCXX_LINE(73);
		std::shared_ptr<haxe::StackItem> s = (*_g1)[_g];

		HCXX_LINE(73);
		++_g;
		HCXX_LINE(74);
		b->b += "\nCalled from "s;
		HCXX_LINE(75);
		haxe::_CallStack::CallStack_Impl_::itemToString(b, s);
	};

	HCXX_LINE(77);
	return b->b;
}

void haxe::_CallStack::CallStack_Impl_::itemToString(std::shared_ptr<StringBuf> b, std::shared_ptr<haxe::StackItem> s) {
	HCXX_STACK_METHOD("C:\\HaxeToolkit\\haxe\\std/haxe/CallStack.hx"s, 155, 2, "haxe._CallStack.CallStack_Impl_"s, "itemToString"s);

	HCXX_LINE(156);
	switch(s->index) {
		case 0: {
			HCXX_LINE(158);
			b->b += "a C function"s;
			break;
		}
		case 1: {
			HCXX_LINE(159);
			std::string _g = s->getModule().m;
			HCXX_LINE(159);
			std::string m = _g;

			HCXX_LINE(160);
			b->b += "module "s;
			HCXX_LINE(161);
			b->b += Std::string(m);
			break;
		}
		case 2: {
			HCXX_LINE(162);
			std::optional<std::shared_ptr<haxe::StackItem>> _g = s->getFilePos().s;
			HCXX_LINE(162);
			std::string _g1 = s->getFilePos().file;
			HCXX_LINE(162);
			int _g2 = s->getFilePos().line;
			HCXX_LINE(162);
			std::optional<int> _g3 = s->getFilePos().column;
			HCXX_LINE(162);
			std::optional<std::shared_ptr<haxe::StackItem>> s2 = _g;
			HCXX_LINE(162);
			std::string file = _g1;
			HCXX_LINE(162);
			int line = _g2;
			HCXX_LINE(162);
			std::optional<int> col = _g3;

			HCXX_LINE(163);
			if(s2.has_value()) {
				HCXX_LINE(164);
				haxe::_CallStack::CallStack_Impl_::itemToString(b, s2.value_or(nullptr));
				HCXX_LINE(165);
				b->b += " ("s;
			};

			HCXX_LINE(167);
			b->b += Std::string(file);
			HCXX_LINE(168);
			b->b += " line "s;
			HCXX_LINE(169);
			b->b += Std::string(line);

			HCXX_LINE(170);
			if(col.has_value()) {
				HCXX_LINE(171);
				b->b += " column "s;
				HCXX_LINE(172);
				b->b += Std::string(col);
			};
			HCXX_LINE(174);
			if(s2.has_value()) {
				HCXX_LINE(175);
				b->b += ")"s;
			};
			break;
		}
		case 3: {
			HCXX_LINE(176);
			std::optional<std::string> _g = s->getMethod().classname;
			HCXX_LINE(176);
			std::string _g1 = s->getMethod().method;
			HCXX_LINE(176);
			std::optional<std::string> cname = _g;
			HCXX_LINE(176);
			std::string meth = _g1;
			HCXX_LINE(177);
			std::optional<std::string> tempMaybeString;

			HCXX_LINE(177);
			if(!cname.has_value()) {
				HCXX_LINE(177);
				tempMaybeString = "<unknown>"s;
			} else {
				HCXX_LINE(177);
				tempMaybeString = cname;
			};

			HCXX_LINE(177);
			b->b += Std::string(tempMaybeString.value());
			HCXX_LINE(178);
			b->b += "."s;
			HCXX_LINE(179);
			b->b += Std::string(meth);
			break;
		}
		case 4: {
			HCXX_LINE(180);
			std::optional<int> _g = s->getLocalFunction().v;
			HCXX_LINE(180);
			std::optional<int> n = _g;

			HCXX_LINE(181);
			b->b += "local function #"s;
			HCXX_LINE(182);
			b->b += Std::string(n);
			break;
		}
		default: {}
	};
}
