package haxe3ds.services;

enum MediaType {
    NAND;
    SD;
    GAME_CARD;
}

@:cppFileCode("
#include <3ds.h>
")

/**
 * File System Service.
 * 
 * !! WIP !!
 * 
 * @since 1.1.0
 */
class FS {
    /**
     * Initializes FS.
     */
    @:native("fsInit")
    public static function init() {}

    /**
     * Exits FS.
     */
    @:native("fsExit")
    public static function exit() {}

    /**
     * Gets whether an SD card is detected.
     * @return If the SDMC is found and detected.
     */
    public static function isSDMCDetected():Bool {
        var ret:Bool = false;
        untyped __cpp__('FSUSER_IsSdmcDetected(&ret)');
        return ret;
    }

    /**
     * Gets whether the SD card is writable.
     * @return `true` If the SDMC can be writable, else `false`.
     */
    public static function isSDMCWritable():Bool {
        var ret:Bool = false;
        untyped __cpp__('FSUSER_IsSdmcDetected(&ret)');
        return ret;
    }
}