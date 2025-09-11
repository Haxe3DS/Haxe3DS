package haxe3ds.services;

import cxx.num.UInt8;
import cxx.num.UInt32;
import cxx.num.UInt64;

typedef FRDPreference = {
    /**
     * Determines whether friends are notified of the current user's online status.
     */
    publicMode:Bool,

    /**
     * Determines whether friends are notified of the application that the current user is running.
     */
    showGameName:Bool,

    /**
     * Determines whether to display the current user's game history.
     */
    showPlayedGame:Bool
}

typedef FRDKey = {
    /**
     * The Principal ID Tied to an account.
     */
    principalID:UInt32,

	/**
	 * The local friend code found in your `Friend List` app.
	 */
	localFriendCode:UInt64
}

typedef FRDProfile = {
    /**
     * The region code for the hardware.
     */
    region:UInt8,

    /**
     * Country Code.
     */
    country:UInt8,

    /**
     * Area Code.
     */
    area:UInt8,

    /**
     * Language Code.
     */
    language:UInt8,

    /**
     * Platform Code.
     */
    platform:UInt8
}

/**
 * Friend Services
 */
@:cppFileCode('
#include <3ds.h>
#include <cstring>
#include "haxe3ds_Utils.h"
')
class FRD {
    /**
     * Variable that checks if the user is logged into Nintendo/Pretendo Network.
     * 
     * Always returns `false`?
     */
    public static var me_loggedIn(default, null):Bool = false;

    /**
     * Variable that checks if the user is connected to the internet.
     * 
     * Always returns `false`?
     */
    public static var me_isOnline(default, null):Bool = false;

    /**
     * Variable that returns your own friend key.
     */
    public static var me_friendKey(default, null):FRDKey = {
        principalID: 0,
        localFriendCode: 0
    };

    /**
     * Listing of the current user's profile, including their region, platform, language, area and country.
     */
    public static var me_profile(default, null):FRDProfile = {
        region: 0, platform: 0, language: 0, area: 0, country: 0
    }

    /**
     * Variable that gets the current mii name from Friend List.
     * 
     * Origin was in `*u16[10]` which was converted to a string.
     */
    public static var me_miiName(default, null):String = "";

    /**
     * Variable for this ID of the current local account.
     */
    public static var me_localAccountId(default, null):UInt8 = 0;

    /**
     * Variable that gets the current comment from Friend List, this is received from `Friend List` > `Your Profile`.
     * 
     * Origin was in `*u16[10]` which was converted to a string.
     */
    public static var me_comment(default, null):String = "";

    /**
     * Variable struct for your current preference usage that can be set on `Friend List` > `Settings`
     */
    public static var me_preference(get, set):FRDPreference;
    static function get_me_preference():FRDPreference {
        var prefs:FRDPreference = {
            publicMode: false,
            showGameName: false,
            showPlayedGame: false
        }
        untyped __cpp__('FRD_GetMyPreference(&prefs->publicMode, &prefs->showGameName, &prefs->showGameName)');
        return prefs;
    }
    static function set_me_preference(me_preference:FRDPreference):FRDPreference {
        untyped __cpp__('FRDA_UpdatePreference(me_preference->publicMode, me_preference->showGameName, me_preference->showGameName)');
        return me_preference;
    }

    /**
     * Initializes friend services.
     * @param forceUser Whether or not to force using the user service frd:u instead of the default (admin service frd:a).
     */
    public static function init(forceUser:Bool) {
        untyped __cpp__('
            frdInit(forceUser);
            FRD_HasLoggedIn(&me_loggedIn);
            FRD_IsOnline(&me_isOnline);

            FriendKey key;
            FRD_GetMyFriendKey(&key);
            me_friendKey->principalID     = key.principalId;
            me_friendKey->localFriendCode = key.localFriendCode;

            Profile prof;
            FRD_GetMyProfile(&prof);
            me_profile->region = prof.region;
            me_profile->platform = prof.platform;
            me_profile->language = prof.language;
            me_profile->area = prof.area;
            me_profile->country = prof.country;

            MiiScreenName n;
            FRD_GetMyScreenName(&n);
            me_miiName = u16ToString(n, MII_NAME_LEN);

            FriendComment c;
            FRD_GetMyComment(&c);
            me_comment = u16ToString(c, FRIEND_COMMENT_LEN);

            FRD_GetMyLocalAccountId(&me_localAccountId);
        ');
    }

    /**
     * Changes the Friend List's presence.
     * @param textToUse Text to set as, maximum 127 characters.
     * @return `true` if successful, `false` if fail.
     */
    public static function updatePresence(textToUse:String):Bool {
        untyped __cpp__('
            const char* text = textToUse.c_str();
            FriendGameModeDescription desc;
            memset(desc, 0, sizeof(desc));
            utf8_to_utf16(desc, (const uint8_t*)text, FRIEND_GAME_MODE_DESCRIPTION_LEN - 1);
            
            Presence frdPres;
            memset(&frdPres, 0, sizeof(frdPres));

            u64 tid;
            APT_GetProgramID(&tid);
            
            frdPres.joinAvailabilityFlag = 1;
            frdPres.matchmakeSystemType  = 0;
            frdPres.joinGameId           = tid;
            frdPres.joinGameMode         = 0;
            frdPres.ownerPrincipalId     = 0;
            
            return R_SUCCEEDED(FRD_UpdateMyPresence(&frdPres, &desc));
        ');
        return false;
    }

    /**
     * Exits friend services.
     */
    @:native("frdExit")
    public static function exit() {}
}