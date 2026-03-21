#pragma once

#include <3ds.h>
#include <stdio.h>

#define CLAMP(var, x, y) ((var) < (x) ? (x) : (var) > (y) ? (y) : (var))
#define MIN(x, y) ((x) < (y) ? (x) : (y))

#define RETURN_NULL_IF_FAILED(x) \
	{ \
		Result code = x; \
		if R_FAILED(code) { \
			printf(#x " FAILED! Error Code: 0x%lX  L:%d M:%d S:%d D:%d", code, R_LEVEL(code), R_MODULE(code), R_SUMMARY(code), R_DESCRIPTION(code)); \
			return null(); \
		} \
	}

#define RETURN_RESULT_IF_FAILED(x) \
	{ \
		Result code = x; \
		if R_FAILED(code) { \
			printf(#x " FAILED! Error Code: 0x%lX  L:%d M:%d S:%d D:%d", code, R_LEVEL(code), R_MODULE(code), R_SUMMARY(code), R_DESCRIPTION(code)); \
			return code; \
		} \
	}

#define TRANSFER(input, output) \
	([&]{ \
		size_t i = 0; \
		for (; i < sizeof(output); i++) { \
			if (input[i] == 0) break; \
			output[i] = input[i]; \
		} \
		return i; \
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