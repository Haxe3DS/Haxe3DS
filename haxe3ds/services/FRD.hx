package haxe3ds.services;

import haxe3ds.Types.Result;
import cxx.num.UInt8;
import cxx.num.UInt32;
import cxx.num.UInt64;

/**
 * Documentation on the relationship that has happend.
 */
enum FRDRelationship {
    /**
     * The target has been added locally and on the server, but is only "provisionally registered." The target has not added you as a friend.
     */
    NOT_REGISTERED;

    /**
     * The target has been added locally and on the server and is fully registered: the target has also added you as a friend. 
     */
    REGISTERED;

    /**
     * No relationship between you and the target has been found: neither you nor the target have added each other. 
     */
    NOT_FOUND;

    /**
     * The relationship has been deleted: the target has deleted your friend card. 
     */
    DELETED;

    /**
     * The target has been added locally: you were not online when you added the target. (presumably only happens when the "Local" method of adding a friend is used. When the system connects to the internet, a background task runs to register this relationship on the friends server.) 
     */
    LOCAL_ADDED;

    /**
     * Given integer is unknown, likely mismatched value.
     */
    UNKNOWN;
}

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
}

/**
 * The current friend's details.
 * 
 * @since 1.4.0
 */
typedef FRDFriendDetail = {
    /**
     * The friend's current comment specified from the friend list.
     * 
     * Origin was in `*u16[10]` which was converted to a string.
     */
    var comment:String;

    /**
     * The current display name specified from their friend card in the friend list.
     * 
     * Origin was in `*u16[10]` which was converted to a string.
     */
    var displayName:String;

    /**
     * Listing of the current friend's profile, including their region, language, area and country.
     */
    var profile:FRDProfile;

    /**
     * Current Added Timestamp from your friend's profile.
     */
    var addedTimestamp:UInt64;

    /**
     * The Principal ID Tied to their friend's account.
     */
    var principalID:UInt32;

    /**
     * Whatever or not his/their mii is a male.
     */
    var male:Bool;

    /**
     * The friend's current relationship.
     * 
     * @see `FRDRelationship` struct.
     */
    var relationship:FRDRelationship;

    /**
     * The friend's favorite game in title id.
     */
    var favoriteGameTID:UInt64;
}

/**
 * Friend Services.
 * 
 * @since 1.2.0
 */
@:cppFileCode('
#include <cstring>
#include "haxe3ds_Utils.h"
')
class FRD {
    /**
     * Variable that checks if the user is logged into Nintendo/Pretendo Network.
     */
    public static var me_loggedIn(get, null):Bool;
    static function get_me_loggedIn():Bool {
        var out:Bool = false;
        untyped __cpp__('FRD_HasLoggedIn(&out)');
        return out;
    }

    /**
     * Variable that checks if the user is connected to the internet and connected to their servers.
     */
    public static var me_isOnline(get, null):Bool;
    static function get_me_isOnline():Bool {
        var out:Bool = false;
        untyped __cpp__('FRD_IsOnline(&out)');
        return out;
    }

    /**
     * The Principal ID Tied to your account.
     */
    public static var me_principalID(default, null):UInt32 = 0;

    /**
     * Listing of the current user's profile, including their region, language, area and country.
     */
    public static var me_profile(default, null):FRDProfile = {
        region: 0, language: 0, area: 0, country: 0
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
    public static var me_comment(get, null):String;
    static function get_me_comment():String {
        var out:String = "";

        untyped __cpp__('
            FriendComment c;
            FRD_GetMyComment(&c);
            out = u16ToString(c, FRIEND_COMMENT_LEN);
        ');

        return out;
    }

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
     */
    public static function init() {
        untyped __cpp__('
            frdInit(false);

            FriendKey key;
            FRD_GetMyFriendKey(&key);
            me_principalID = key.principalId;

            Profile prof;
            FRD_GetMyProfile(&prof);
            me_profile->region = prof.region;
            me_profile->language = prof.language;
            me_profile->area = prof.area;
            me_profile->country = prof.country;

            MiiScreenName n;
            FRD_GetMyScreenName(&n);
            me_miiName = u16ToString(n, MII_NAME_LEN);

            FRD_GetMyLocalAccountId(&me_localAccountId);
        ');
    }

    /**
     * Changes the Friend List's presence.
     * @param textToUse Text to set as, maximum 127 characters and 1 new line (multiple will be cut by `FRD_UpdateMyPresence`).
     * @return Result code of whetever something from the services went wrong.
     */
    public static function updatePresence(textToUse:String):Result {
        untyped __cpp__('
            FriendGameModeDescription desc;
            memset(desc, 0, sizeof(desc));
            utf8_to_utf16(desc, (const uint8_t*)textToUse.c_str(), FRIEND_GAME_MODE_DESCRIPTION_LEN);
            
            Presence frdPres;
            memset(&frdPres, 0, sizeof(frdPres));

            u64 tid;
            APT_GetProgramID(&tid);
            
            frdPres.joinAvailabilityFlag = 1;
            frdPres.matchmakeSystemType  = 0;
            frdPres.joinGameId           = tid;
            frdPres.joinGameMode         = 0;
            frdPres.ownerPrincipalId     = 0;
        ');

        return untyped __cpp__('FRD_UpdateMyPresence(&frdPres, &desc)');
    }

    /**
     * Updates your own friend comment with the string specified. (Just to know please don't try to bypass profanity, maybe you'll get banned!)
     * @param textToUse Text to use, Maximum 16 characters.
     * @return Result code of whetever something went wrong.
     * @since 1.4.0
     */
    public static function updateComment(textToUse:String):Result {
        untyped __cpp__('
            FriendComment desc;
            memset(desc, 0, sizeof(desc));
            utf8_to_utf16(desc, (const uint8_t*)textToUse.c_str(), FRIEND_COMMENT_LEN)
        ');

        return untyped __cpp__('FRDA_UpdateComment(&desc)');
    }

    /**
     * Configures the current client session to allow processing of internal friend-services tasks during sleep mode.
     */
    public static var halfAwake(null, set):Bool;
    static function set_halfAwake(halfAwake:Bool):Bool {
        untyped __cpp__('FRD_AllowHalfAwake(halfAwake)');
        return halfAwake;
    }

    /**
     * Gets the whole friend profile specified.
     * @param maskNonAscii Whether or not to replace all non-ASCII characters with question marks ('?') if the given character set doesn't match that of the corresponding friend's Mii data.
     * @param profanityFlag Setting this to true replaces the screen names with all question marks ('?') if profanityFlag is also set in the corresponding friend's Mii data.
     * @return Array of typedef `FRDFriendDetail`, will return 0 if one of the FRD functions failed, or has 0 friends total.
     * @since 1.4.0
     */
    public static function getFriendsProfile(maskNonAscii:Bool = false, profanityFlag:Bool = false):Array<FRDFriendDetail> {
        var out:Array<FRDFriendDetail> = [];

        untyped __cpp__('
            FriendKey list[FRIEND_LIST_SIZE] = {};
            u32 l = 0;
            if (R_FAILED(FRD_GetFriendKeyList(list, &l, 0, FRIEND_LIST_SIZE))) {
                return {};
            }

            FriendInfo prof[100] = {};
            if (R_FAILED(FRD_GetFriendInfo(prof, list, l, false, false))) {
                return {};
            }
        ');

        for (i in 0...untyped __cpp__('l')) {
            untyped __cpp__('
                FriendInfo f = prof[{0}]
            ', i);

            var relation:FRDRelationship = UNKNOWN;
            switch(untyped __cpp__('f.relationship')) {
                case 0: relation = NOT_REGISTERED;
                case 1: relation = REGISTERED;
                case 2: relation = NOT_FOUND;
                case 3: relation = DELETED;
                case 4: relation = LOCAL_ADDED;
            };

            out.push({
                comment: untyped __cpp__('u16ToString(f.friendProfile.personalMessage, sizeof(f.friendProfile.personalMessage))'),
                displayName: untyped __cpp__('u16ToString(f.screenName, sizeof(f.screenName))'),
                profile: {
                    region: untyped __cpp__('f.friendProfile.profile.region'),
                    country: untyped __cpp__('f.friendProfile.profile.country'),
                    area: untyped __cpp__('f.friendProfile.profile.area'),
                    language: untyped __cpp__('f.friendProfile.profile.language')
                },
                addedTimestamp: untyped __cpp__('f.addedTimestamp'),
                principalID: untyped __cpp__('f.friendKey.principalId'),
                male: untyped __cpp__('!f.mii.miiData.mii_details.sex'),
                relationship: relation,
                favoriteGameTID: untyped __cpp__('f.friendProfile.favoriteGame.titleId')
            });
        }

        return out;
    }

    /**
     * Exits friend services.
     */
    @:native("frdExit")
    public static function exit() {}
}