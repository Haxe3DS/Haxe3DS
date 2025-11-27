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

Thread fastCreateThread(ThreadFunc function, void* arg) {
	s32 priority;
	svcGetThreadPriority(&priority, CUR_THREAD_HANDLE);
	priority -= 1;
	return threadCreate(function, arg, 32768, priority < 0x18 ? 0x18 : priority > 0x3F ? 0x3F : priority, -1, false);
}