package haxe3ds.stdutil;

import cxx.DynamicToString;

using StringTools;

/**
 * Standard Library for String Utility.
 * 
 * @since 1.3.0
 */
class StringUtil {
    /**
     * Formats a string with arguments provided, Example: `Hello, {}!` with args ["World"] -> `Hello, World!`
     * 
     * Basically the same as `std::format`.
     * 
     * @param format Formatter of the string to utilise.
     * @param args Arguments as in array to use.
     * @return String formatted.
     */
    public static function format(format:String, args:Array<Dynamic>):String {
        final arr:Array<String> = format.split("{}");
        var out:String = arr[0];
    
        for (i in 1...arr.length) {
            final ins:DynamicToString = args.length >= i ? args[i-1] : "{}";
            out += ins + arr[i];
        }
    
        return out;
    }
}