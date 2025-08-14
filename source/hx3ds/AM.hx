package hx3ds;

import hx3ds.FS.MediaType;

@:cppInclude("3ds.h")
@:cppFileCode("FS_MediaType getFS(std::shared_ptr<hx3ds::MediaType> media) {
    FS_MediaType type;
    switch(media->index) {
    	case 0: type = MEDIATYPE_NAND;
    	case 1: type = MEDIATYPE_SD;
    	case 2: type = MEDIATYPE_GAME_CARD;
    }
    return type;
}")
class AM {
    /**
     * Initializes AM. This doesn't initialize with "am:app", see amAppInit().
     */
    @:native("amInit")
    public static function init():Void {};

    /**
     * Initializes AM with a service which has access to the amapp-commands. This should only be used when using the amapp commands, not non-amapp AM commands.
     */
    @:native("amAppInit")
    public static function appInit():Void {};

    /**
     * Exits AM.
     */
    @:native("amExit")
    public static function exit():Void {};

    /**
     * Gets the number of titles for a given media type.
     * @param mediatype Media type to get titles from.
     * @return Total title count in media.
     */
    public static function getTitleCount(mediatype:MediaType):Int {
        var ret:UInt32 = 0;
        untyped __cpp__("AM_GetTitleCount(getFS(mediatype), &ret)");
        return ret;
    }

    /**
     * Gets the number of tickets installed on the system.
     * @return Count of tickets found.
     */
    public static function getTicketCount():Int {
        var ret:UInt32 = 0;
        untyped __cpp__("AM_GetTicketCount(&ret)");
        return ret;
    }

    /**
     * Gets a 32-bit device-specific ID.
     * @return The current device ID.
     */
    public static function getDeviceID():UInt32 {
        var ret:UInt32 = 0;
        untyped __cpp__("AM_GetDeviceId(&ret)");
        return ret;
    }
}