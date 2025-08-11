#include "hx3ds_News.h"

#include <cstdint>
#include <memory>
#include <string>
#include "3ds.h"
#include "haxe_NativeStackTrace.h"

using namespace std::string_literals;

void hx3ds::News::newsInit() {
	HCXX_STACK_METHOD("source/hx3ds/News.hx"s, 9, 5, "hx3ds.News"s, "newsInit"s);


}

void hx3ds::News::newsExit() {
	HCXX_STACK_METHOD("source/hx3ds/News.hx"s, 15, 5, "hx3ds.News"s, "newsExit"s);


}

void hx3ds::News::addNotification(std::string title, std::string message) {
	HCXX_STACK_METHOD("source/hx3ds/News.hx"s, 22, 5, "hx3ds.News"s, "addNotification"s);

	HCXX_LINE(23);
	u16 OutTitle[32] = {0};
	u16 OutMessage[256] = {0};

	const char* t = title.c_str();
	const char* m = message.c_str();

	for (size_t i = 0; i < title.size(); i++) OutTitle[i] = t[i];
	for (size_t i = 0; i < message.size(); i++) OutMessage[i] = m[i];

	NEWS_AddNotification(OutTitle, title.size(), OutMessage, message.size(), NULL, 0, false);
}

uint32_t hx3ds::News::getTotalNotifications() {
	HCXX_STACK_METHOD("source/hx3ds/News.hx"s, 38, 5, "hx3ds.News"s, "getTotalNotifications"s);

	HCXX_LINE(39);
	uint32_t out = (uint32_t)(0);

	HCXX_LINE(40);
	NEWS_GetTotalNotifications(&out);

	HCXX_LINE(41);
	return out;
}