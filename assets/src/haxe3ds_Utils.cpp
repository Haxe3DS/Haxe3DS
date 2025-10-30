#include "haxe3ds_Utils.h"

CFG_Language getFromCFGC(int e) {
    switch(e) {
        case 0:  return CFG_LANGUAGE_DEFAULT;
        case 1:  return CFG_LANGUAGE_JP;
        case 2:  return CFG_LANGUAGE_EN;
        case 3:  return CFG_LANGUAGE_FR;
        case 4:  return CFG_LANGUAGE_DE;
        case 5:  return CFG_LANGUAGE_IT;
        case 6:  return CFG_LANGUAGE_ES;
        case 7:  return CFG_LANGUAGE_ZH;
        case 8:  return CFG_LANGUAGE_KO;
        case 9:  return CFG_LANGUAGE_NL;
        case 10: return CFG_LANGUAGE_PT;
        case 11: return CFG_LANGUAGE_RU;
        case 12: return CFG_LANGUAGE_TW;
		default: return CFG_LANGUAGE_DEFAULT;
    }
}

std::string u16ToString(u16* i, size_t ln) {
    u8 out[ln+1];
    ssize_t l = utf16_to_utf8(out, i, ln);
    if (l > -1) out[l] = '\0';
    return std::string(reinterpret_cast<char*>(out));
}

Thread fastCreateThread(ThreadFunc function, void* arg) {
    s32 priority;
    svcGetThreadPriority(&priority, CUR_THREAD_HANDLE);
    priority -= 1;
    return threadCreate(function, arg, 32768, priority < 0x18 ? 0x18 : priority > 0x3F ? 0x3F : priority, -1, false);
}