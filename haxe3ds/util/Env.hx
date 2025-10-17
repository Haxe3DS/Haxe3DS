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

    /**
     * Getter Variable that checks if it's using from a console and not from an emulator (aka tries to connect to port "hb:ldr" and closes if success).
     * 
     * @since 1.5.0
     */
    public static var isUsing3DS(get, null):Bool;
    static function get_isUsing3DS():Bool {
        var isLuma:Bool = false;
        untyped __cpp__('
            Handle lumaCheck;
            isLuma = R_SUCCEEDED(svcConnectToPort(&lumaCheck, "hb:ldr"));
            if(isLuma) svcCloseHandle(lumaCheck)
        ');
        return isLuma;
    }
}