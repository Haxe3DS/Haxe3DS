#pragma once

#include "haxe3ds_services_GFX.h"
#include <string>

#define UNUSED_VAR(var) ((void)&var);

#define u16ToString(input) \
    ([input]{ \
		size_t iSize = sizeof(input); \
        u8 _out[iSize + 1] = {0}; \
        ssize_t size = utf16_to_utf8(_out, input, iSize); \
        if (size < 0) _out[size] = '\0'; \
        return std::string(reinterpret_cast<char*>(_out)); \
    }());
	
CFG_Language getFromCFGC(int e);
Thread fastCreateThread(ThreadFunc function, void* arg);