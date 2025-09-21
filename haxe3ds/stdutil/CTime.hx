package haxe3ds.stdutil;

@:cppFileCode('
#include <ctime>
using namespace std;

tm getNow() {
    time_t timestamp = time(&timestamp);
    struct tm datetime = *localtime(&timestamp);
    return datetime;
}
')

/**
 * Standard Library using `ctime`.
 * 
 * This is not the same as `haxe.std.Date`!
 */
class CTime {
    /**
     * Gets the current second.
     * 
     * Ranges from 0 to 59
     */
    public static var second(get, null):Int;
    static function get_second():Int {
        return untyped __cpp__('getNow().tm_sec');
    }

    /**
     * Gets the current minute.
     *
     * Ranges from 0 to 59
     */
    public static var minute(get, null):Int;
    static function get_minute():Int {
        return untyped __cpp__('getNow().tm_min');
    }

    /**
     * Gets the current hour.
     * 
     * Ranges from 0 to 23
     */
    public static var hour(get, null):Int;
    static function get_hour():Int {
        return untyped __cpp__('getNow().tm_hour');
    }

    /**
     * Gets the current day.
     * 
     * Ranges from 0 to 28-31
     */
    public static var day(get, null):Int;
    static function get_day():Int {
        return untyped __cpp__('getNow().tm_mday');
    }

    /**
     * Gets the current month.
     * 
     * Ranges from 0 to 11.
     * 
     * Example:
     * ```
     * final monthNames:Array<String> = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "September", "October", "November", "December"];
     * 
     * trace('Current month is ${monthNames[STDTime.month]}');
     * ```
     */
    public static var month(get, null):Int;
    static function get_month():Int {
        return untyped __cpp__('getNow().tm_mon');
    }

    /**
     * Gets the current years.
     * 
     * In the tm struct, `tm_year` does not count at 1900, so it's being added to that.
     */
    public static var year(get, null):Int;
    static function get_year():Int {
        return untyped __cpp__('getNow().tm_year + 1900');
    }

    /**
     * Gets the current week day.
     */
    public static var weekday(get, null):Int;
    static function get_weekday():Int {
        return untyped __cpp__('getNow().tm_wday');
    }

    /**
     * Convert the time now to a formatted string: `Wed Sep 21 10:27:52 2011`
     * 
     * Where:
     * - `Wed` is the substring version of the current weekday in string.
     * - `Sep` is the substring version of the current month in string.
     * - `21` is the integer for the current month day.
     * - `10:27:52` is the string of the current timestamp.
     * - `2011` is the integer for the current year.
     * 
     * @return Timed String
     */
    public static function toString():String {
        var out:String = "";
        untyped __cpp__('
            tm shit = getNow();
	        out = std::string(std::asctime(&shit))
        ');
        return out;
    }
}