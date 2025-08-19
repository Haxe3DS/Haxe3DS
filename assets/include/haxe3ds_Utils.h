#pragma once

#include "haxe3ds_Error.h"
#include "haxe3ds_CFGU.h"
#include <3ds.h>

errorType getFromET(std::shared_ptr<haxe3ds::ErrorType> e);
CFG_Language getFromCFGC(std::shared_ptr<haxe3ds::CFG_Language> e);
errorReturnCode getFromERC(std::shared_ptr<haxe3ds::ErrorReturnCode> e);