#pragma once

#include "haxe3ds_applet_Error.h"
#include "haxe3ds_services_CFGU.h"
#include <3ds.h>
    
CFG_Language getFromCFGC(int e);
std::string u16ToString(u16* i, size_t ln);