package haxe3ds.services;

/**
 * News (Notification Appleter) Service.
 * 
 * Currently a total train wreck caused by LibCTRU devs (especially `News.totalNotifications`)
 */
@:cppInclude("3ds.h")
class News {
    /**
     * Initializes NEWS.
     */
    public static function init() {
        untyped __cpp__('
            newsInit();

            Result r = 0;
            if (R_FAILED(r = NEWS_GetTotalNotifications(&totalNotifications))) {
                totalNotifications = r;
            }
        ');
    };

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
        untyped __cpp__("
            u16 OutTitle[32] = {0};
            u16 OutMessage[4096] = {0}; // cause why not lool

            const char* t = title.c_str();
            const char* m = message.c_str();

            for (size_t i = 0; i < title.size(); i++) OutTitle[i] = t[i];
            for (size_t i = 0; i < message.size(); i++) OutMessage[i] = m[i];

            NEWS_AddNotification(OutTitle, title.size(), OutMessage, message.size(), NULL, 0, false)
        ");
    }

    /**
     * Variable property that gets current total notifications number.
     * 
     * Error Codes:
     * - `0xD900182F (3640662063)` - Due to LibCTRU's amazing coding skills, they've used `news:u` instead of `news:s` and thus is the reason why it caused this amazing error.
     * 
     * @see https://github.com/devkitPro/libctru/issues/587 `(0xD900182F)`
     */
    public static var totalNotifications(default, null):UInt32;
}