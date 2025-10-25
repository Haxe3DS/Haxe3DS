#pragma once

#include "haxe3ds_services_GFX.h"
#include <string>
    
CFG_Language getFromCFGC(int e);
std::string u16ToString(u16* i, size_t ln);
Thread fastCreateThread(ThreadFunc function, void* arg);