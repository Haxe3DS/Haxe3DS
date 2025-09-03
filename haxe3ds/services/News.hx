package haxe3ds.services;

@:cppInclude("3ds.h")
class News {
    /**
     * Initializes NEWS.
     */
    @:native("newsInit")
    public static function init() {};

    /**
     * Exits NEWS.
     */
    @:native("newsExit")
    public static function exit() {};

    /**
     * Adds a notification to the home menu Notifications applet.
     * @param title UTF-16 title of the notification.
     * @param message UTF-16 message of the notification, or NULL for no message.
     */
    public static function addNotification(title:String, message:String) {
        untyped __cpp__("u16 OutTitle[32] = {0};
u16 OutMessage[4096] = {0}; // cause why not lool

const char* t = title.c_str();
const char* m = message.c_str();

for (size_t i = 0; i < title.size(); i++) OutTitle[i] = t[i];
for (size_t i = 0; i < message.size(); i++) OutMessage[i] = m[i];

NEWS_AddNotification(OutTitle, title.size(), OutMessage, message.size(), NULL, 0, false)");
    }

    /**
     * Gets current total notifications number.
     */
    public static function getTotalNotifications():UInt32 {
        var out:UInt32 = 0;
        untyped __cpp__("NEWS_GetTotalNotifications(&out)");
        return out;
    }
}