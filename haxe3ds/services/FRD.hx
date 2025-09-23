package haxe3ds.services;

import cxx.num.UInt8;
import cxx.num.UInt32;
import cxx.num.UInt64;

/**
 * Preference from your friend list.
 */
typedef FRDPreference = {
    /**
     * Determines whether friends are notified of the current user's online status.
     */
    var publicMode:Bool;

    /**
     * Determines whether friends are notified of the application that the current user is running.
     */
    var showGameName:Bool;

    /**
     * Determines whether to display the current user's game history.
     */
    var showPlayedGame:Bool;
}

/**
 * The friend key, which contains the PID and LFC
 */
typedef FRDKey = {
    /**
     * The Principal ID Tied to an account.
     */
    var principalID:UInt32;

	/**
	 * The local friend code found in your `Friend List` app.
	 */
	var localFriendCode:UInt64;
}

/**
 * The profile type-definition.
 */
typedef FRDProfile = {
    /**
     * The region code for the hardware.
     */
    var region:UInt8;

    /**
     * Country Code.
     */
    var country:UInt8;

    /**
     * Area Code.
     */
    var area:UInt8;

    /**
     * Language Code.
     */
    var language:UInt8;

    /**
     * Platform Code.
     */
    var platform:UInt8;
}

/**
 * Friend Services
 * 
 * @since 1.2.0
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
     * 
     * To edit your preference, you just do this:
     * ```
     * var prefs = FRD.me_preference;
     * prefs.publicMode = false;
     * prefs.showPlayedGame = false;
     * FRD.me_preference = prefs;
     * ```
     */
    public static var me_preference(get, set):FRDPreference;
    static function get_me_preference():FRDPreference {
        var prefs:FRDPreference = {
            publicMode: false,
            showGameName: false,
            showPlayedGame: false
        }
        untyped __cpp__('FRD_GetMyPreference(&prefs->publicMode, &prefs->showGameName, &prefs->showPlayedGame)');
        return prefs;
    }
    static function set_me_preference(me_preference:FRDPreference):FRDPreference {
        untyped __cpp__('FRDA_UpdatePreference(me_preference->publicMode, me_preference->showGameName, me_preference->showPlayedGame)');
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
     * @param textToUse Text to set as, maximum 127 characters and 1 new line (multiple will be cut by `FRD_UpdateMyPresence`).
     * @return `true` if successful, `false` if fail.
     */
    public static function updatePresence(textToUse:String):Bool {
        untyped __cpp__('
            FriendGameModeDescription desc;
            memset(desc, 0, sizeof(desc));
            utf8_to_utf16(desc, (const uint8_t*)textToUse.c_str(), FRIEND_GAME_MODE_DESCRIPTION_LEN - 1);
            
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