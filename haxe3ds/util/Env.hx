package haxe3ds.util;

/**
 * Environnment settings for this application.
 * 
 * @since 1.3.0
 */
@:cppFileCode("#include <3ds.h>")
class Env {
    /**
     * Getter Variable that checks if it's running in 3DSX application using `envIsHomebrew()`, true if so, false if running in a CIA Application.
     */
    public static var is3DSX(get, null):Bool;
    static function get_is3DSX():Bool {
        return untyped __cpp__('envIsHomebrew()');
    }
}