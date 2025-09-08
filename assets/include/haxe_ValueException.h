#pragma once

#include <any>
#include <optional>
#include "_HaxeUtils.h"
#include "haxe_Exception.h"

namespace haxe {

class ValueException: public haxe::Exception {
public:
	std::any value;
	std::string tempString;

	ValueException(std::any value2, std::optional<haxe::Exception> previous = std::nullopt, std::optional<std::any> native = std::nullopt);
	std::any unwrap() override;

	HX_COMPARISON_OPERATORS(ValueException)
};

}
