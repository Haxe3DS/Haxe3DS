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
    public static function init() {
        untyped __cpp__('
            fsInit();
            FSUSER_IsSdmcDetected(&isSDMCDetected);
            FSUSER_IsSdmcWritable(&isSDMCWritable)
        ');
    }

    /**
     * Variable property that gets whether an SD card is detected.
     * 
     * If the SDMC is found and detected, it returns `true`, else `false`.
     */
    public static var isSDMCDetected(default, null):Bool = false;

    /**
     * Gets whether the SD card is writable.
     * 
     * If the SDMC can be written, it returns `true`, else `false`
     */
    public static var isSDMCWritable(default, null):Bool = false;

    /**
     * Exits FS.
     */
    @:native("fsExit")
    public static function exit() {}
}