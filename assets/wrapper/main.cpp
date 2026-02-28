#include <3ds.h>
#include <hxcpp.h>

extern "C" void __hxcpp_main();
extern "C" void __hxcpp_lib_main();

extern int _hxcpp_argc;
extern char **_hxcpp_argv;

#include <malloc.h>
#include <sys/socket.h>

#define return \
	socExit(); \
	free(SOC_buffer); \
	return

// figured it out myself :)
void HAXE3DS_CTRUException(ERRF_ExceptionInfo* excep, CpuRegisters* regs) {
	consoleInit(GFX_BOTTOM, NULL);
	consoleClear();

	FILE* f = fopen("sdmc:/haxe3ds_exception.log", "w");
	if (!f) {
		hx::Throw(String("[!!] Application Error [!!]\nPlease insert the SD card to save that error."));
	}

	fprintf(f, "App Error [");
	#define CASEPR(x, y) \
		case x: { \
			fprintf(f, y "]\n\n"); \
			break; \
		} \

	switch(excep->type) {
		CASEPR(ERRF_EXCEPTION_PREFETCH_ABORT, "Prefetch Abort")
		CASEPR(ERRF_EXCEPTION_DATA_ABORT, "Data abort")
		CASEPR(ERRF_EXCEPTION_UNDEFINED, "Undefined instruction")
		CASEPR(ERRF_EXCEPTION_VFP, "VFP (floating point) exception")
		default: {
			fprintf(f, "Unknown]\n\n");
			break;
		}
	}

	for (u8 i = 0; i < 13; i++) {
		fprintf(f, "R%02d: 0x%08lX\n", i, regs->r[i]);
	}

	fprintf(f, "\n   SP: 0x%08lX     LR:   0x%08lX\n", regs->sp, regs->lr);
	fprintf(f, "   PC: 0x%08lX   CPSR:   0x%08lX\n", regs->pc, regs->cpsr);
	fprintf(f, "  FSR: 0x%08lX    FAR:   0x%08lX\n", excep->fsr, excep->far);
	fprintf(f, "FPEXC: 0x%08lX   FPI1:   0x%08lX\n", excep->fpexc, excep->fpinst);
	fprintf(f, " FPI2: 0x%08lX", excep->fpinst2);

	fprintf(f, "\n\nhaxelib run haxe3ds -e 0x%lX 0x%lX\nUse the command above to locate which line throws exception from.", regs->pc, regs->lr);
	fclose(f);

	hx::Throw(HX_CSTRING("[!!] Application Error [!!]\n\nThis is caused by an Exception from this Application and NOT a Throw! See the logs file at sdmc:/haxe3ds_exception.log"));
}

extern "C" EXPORT_EXTRA int main() {
	threadOnException(HAXE3DS_CTRUException, RUN_HANDLER_ON_FAULTING_STACK, WRITE_DATA_TO_HANDLER_STACK);

	HX_TOP_OF_STACK
	hx::Boot();

	u32* SOC_buffer = (u32*)memalign(0x1000, 0x100000);
	if R_FAILED(socInit(SOC_buffer, 0x100000)) svcBreak(USERBREAK_PANIC);
	#ifdef HAXE3DS_LINKTO3DS
	int sock = link3dsStdio();
	#endif

	try {
		__boot_all();
		__hxcpp_main();
	} catch (Dynamic d) {
		consoleInit(GFX_TOP, NULL);
		consoleClear();

		printf("[EXCEPTION OCCURRED!]\n%s\n\n", String(d).c_str());
		__hx_dump_stack();
		#ifdef HAXE3DS_LINKTO3DS
		if (sock > 0) closesocket(sock);
		#else
		printf("\nPress [START] to exit Haxe3DS");
		while (hidScanInput(), !(hidKeysDown() & KEY_START) && aptMainLoop());
		#endif

		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}