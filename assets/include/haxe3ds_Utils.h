#pragma once

#include <3ds.h>

// more of a check if result failed
#define RETURN_NULL_IF_FAILED(x) if R_FAILED(x) return null();
#define CLAMP(var, x, y) var < x ? x : var > y ? y : var
#define MIN(x, y) ((x) < (y) ? (x) : (y))

#define TRANSFER(input, output) \
	([&]{ \
		size_t size = MIN(sizeof(input), sizeof(output)); \
		for (size_t i = 0; i < size; i++) { \
			if (input[i] == 0) break; \
			output[i] = input[i]; \
		} \
		return size; \
	}())

#define u16ToString(input) \
	([&]{ \
		size_t iSize = sizeof(input); \
		u8 _out[iSize + 1] = {0}; \
		ssize_t size = TRANSFER(input, _out); \
		if (size == 0) return String(""); \
		return String(reinterpret_cast<char*>(_out)); \
	}())

#define API_GETTER(type, func, value) \
	([&]{ \
		type a = {value}; \
		func(&a); \
		return a; \
	}())

inline Thread fastCreateThread(ThreadFunc function, void* arg) {
	s32 priority;
	svcGetThreadPriority(&priority, CUR_THREAD_HANDLE);
	priority -= 1;
	return threadCreate(function, arg, 32768, CLAMP(priority, 0x18, 0x3F), -1, true);
}