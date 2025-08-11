#pragma once

#include <cstdint>
#include <memory>
#include <string>

namespace hx3ds {

class News {
public:
	static void newsInit();
	static void newsExit();
	static void addNotification(std::string title, std::string message);
	static uint32_t getTotalNotifications();
};

}
