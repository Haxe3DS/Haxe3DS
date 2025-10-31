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
 * Type of the notification that was triggered by the friend list.
 * 
 * @since 1.5.0
 */
enum abstract FRDNotifTypes(Int) {
	/**
	 * The console went online.
	 */
	var SELF_ONLINE = 1;

	/**
	 * The console went offline.
	 */
	var SELF_OFFLINE = 2;

	/**
	 * A friend is now present (went online). 
	 */
	var FRIEND_ONLINE = 3;

	/**
	 * A friend changed their presence, and the current system's JoinGameID is the same as their new or old JoinGameID.
	 */
	var FRIEND_PRESENCE_CHANGED = 4;

	/**
	 * A friend changed their Mii.
	 */
	var FRIEND_MII_CHANGED = 5;

	/**
	 * A friend changed their Profile.
	 * 
	 * @see FRDProfile Struct.
	 */
	var FRIEND_PROFILE_CHANGED = 6;

	/**
	 * A friend is no longer present (went offline).
	 */
	var FRIEND_OFFLINE = 7;

	/**
	 * A friend has added you back as a friend (if you had added them before as a "provisionally registered" friend).
	 */
	var FRIEND_REGISTERED = 8;

	/**
	 * A friend sent you an invitation, and the current system's JoinGameID matches that of the friend.
	 */
	var FRIEND_GOT_INVITED = 9;
}

/**
 * Friend Services.
 * 
 * @since 1.2.0
 */
@:cppFileCode('
#include <cstring>
#include "haxe3ds_Utils.h"

Handle frd_Handle;
Thread frd_Thread;

void threadStart(void* _) {
	while (true) {
		if (svcWaitSynchronization(frd_Handle, 1e10) == 0) {
			NotificationEvent event;
			u32 totalNotifs;
			if (R_FAILED(FRD_GetEventNotification(&event, 1, &totalNotifs))) {
				continue;
			}

			FriendInfo f;
			if (R_FAILED(FRD_GetFriendInfo(&f, &event.sender, 1, false, false))) {
				continue;
			}

			std::shared_ptr<haxe3ds::services::FRDRelationship> relation = haxe3ds::services::FRDRelationship::UNKNOWN();
			switch(f.relationship) {
				case 0: {
					relation = haxe3ds::services::FRDRelationship::NOT_REGISTERED();
					break;
				}
				case 1: {
					relation = haxe3ds::services::FRDRelationship::REGISTERED();
					break;
				}
				case 2: {
					relation = haxe3ds::services::FRDRelationship::NOT_FOUND();
					break;
				}
				case 3: {
					relation = haxe3ds::services::FRDRelationship::DELETED();
					break;
				}
				case 4: {
					relation = haxe3ds::services::FRDRelationship::LOCAL_ADDED();
					break;
				}
				default: {}
			};

			std::shared_ptr<haxe3ds::services::FRDFriendDetail> x = haxe::shared_anon<haxe3ds::services::FRDFriendDetail>(f.addedTimestamp, u16ToString(f.friendProfile.personalMessage, sizeof(f.friendProfile.personalMessage)), u16ToString(f.screenName, sizeof(f.screenName)), f.friendProfile.favoriteGame.titleId, !f.mii.miiData.mii_details.sex, f.friendKey.principalId, haxe::shared_anon<haxe3ds::services::FRDProfile>(f.friendProfile.profile.area, f.friendProfile.profile.country, f.friendProfile.profile.language, f.friendProfile.profile.region), relation);
			if (haxe3ds::services::FRD::notifCallback != nullptr) {
				haxe3ds::services::FRD::notifCallback(x, event.type);
			}
		}
	}
	
	threadExit(0);
}')
class FRD {
	/**
	 * Variable that checks if the user is logged into Nintendo/Pretendo Network.
	 */
	public static var loggedIn(get, null):Bool;
	static function get_loggedIn():Bool {
		var out:Bool = false;
		untyped __cpp__('FRD_HasLoggedIn(&out)');
		return out;
	}

	/**
	 * Variable that checks if the user is connected to the internet and connected to their servers.
	 */
	public static var isOnline(get, null):Bool;
	static function get_isOnline():Bool {
		var out:Bool = false;
		untyped __cpp__('FRD_IsOnline(&out)');
		return out;
	}

	/**
	 * Variable for this ID of the user's current local account.
	 */
	public static var localAccountId(default, null):UInt8 = 0;

	/**
	 * Variable for this user's profile.
	 * 
	 * Can only be usable *if* FRD is initialized, if not initialized yet used anyway: CRASH!
	 * 
	 * Note that it is not going to be updated everytime.
	 */
	public static var myProfile(default, null):FRDFriendDetail;

	/**
	 * Callback handler for notifications called from friends.
	 * 
	 * ### Args:
	 * - `FRDFriendDetail` - The details of the friend that triggered this notification.
	 * - `FRDNotifTypes` - Type of notification it is caused.
	 * 
	 * @since 1.5.0
	 */
	public static var notifCallback:(FRDFriendDetail, FRDNotifTypes)->Void;

	/**
	 * Initializes friend services.
	 */
	public static function init() {
		untyped __cpp__('
			frdInit(false);
			
			svcCreateEvent(&frd_Handle, RESET_ONESHOT);
			FRD_AttachToEventNotification(frd_Handle);
			fastCreateThread(threadStart, NULL);
			
			FriendKey key;
			FriendInfo f;

			FRD_GetMyFriendKey(&key);
			FRD_GetFriendInfo(&f, &key, 1, false, false);
			FRD_GetMyLocalAccountId(&localAccountId);
		');

		// reflaxe.cpp is dumb so i gotta do this to fix compiler error yaywoo
		final _:FRDProfile = null;
		untyped __cpp__('UNUSED_VAR({0})', _);

		final relation:FRDRelationship = switch(untyped __cpp__('f.relationship')) {
			case 0: NOT_REGISTERED;
			case 1: REGISTERED;
			case 2: NOT_FOUND;
			case 3: DELETED;
			case 4: LOCAL_ADDED;
			default: UNKNOWN;
		};

		myProfile = {
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
		};
	}

	/**
	 * Changes the Friend List's presence that is present in the Friend List.
	 * @param textToUse Text to set as, maximum 127 characters and 1 new line (multiple will be cut by `FRD_UpdateMyPresence`).
	 * @return Result code of whetever something from the services went wrong.
	 */
	public static function updatePresence(textToUse:String):Result {
		untyped __cpp__('
			FriendGameModeDescription desc;
			memset(desc, 0, sizeof(desc));
			utf8_to_utf16(desc, (const u8*)textToUse.c_str(), FRIEND_GAME_MODE_DESCRIPTION_LEN);
			
			Presence frdPres;
			memset(&frdPres, 0, sizeof(frdPres));

			u64 tid;
			APT_GetProgramID(&tid);
			
			frdPres.joinAvailabilityFlag = 1;
			frdPres.matchmakeSystemType  = 0;
			frdPres.joinGameId		   = tid;
			frdPres.joinGameMode		 = 0;
			frdPres.ownerPrincipalId	 = 0;
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
			utf8_to_utf16(desc, (const u8*)textToUse.c_str(), FRIEND_COMMENT_LEN)
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
	 * @return Array of typedef `FRDFriendDetail`, will return 0 if one of the FRD functions failed, or has 0 friends total.
	 * @since 1.4.0
	 */
	public static function getFriendsProfile():Array<FRDFriendDetail> {
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

			final relation:FRDRelationship = switch(untyped __cpp__('f.relationship')) {
				case 0: NOT_REGISTERED;
				case 1: REGISTERED;
				case 2: NOT_FOUND;
				case 3: DELETED;
				case 4: LOCAL_ADDED;
				default: UNKNOWN;
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
	 * Frees Thread, Closes handle and Exits friend services.
	 */
	public static function exit() {
		untyped __cpp__('
			threadFree(frd_Thread);
			svcCloseHandle(frd_Handle);
			frdExit()
		');
	}
}