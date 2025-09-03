#pragma once

#include "haxe3ds_applet_Error.h"
#include "haxe3ds_services_CFGU.h"
#include <3ds.h>

errorType getFromET(std::shared_ptr<haxe3ds::applet::ErrorType> e);
CFG_Language getFromCFGC(std::shared_ptr<haxe3ds::services::CFG_Language> e);
errorReturnCode getFromERC(std::shared_ptr<haxe3ds::applet::ErrorReturnCode> e);