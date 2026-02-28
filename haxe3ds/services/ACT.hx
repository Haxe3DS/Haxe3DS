package haxe3ds.services;

import haxe3ds.Types.Result;
import haxe3ds.Types.NanoTime;
import cpp.UInt32;
import cpp.UInt16;
import cpp.UInt8;

/**
 * ACT's Account Information.
 * 
 * @since 1.4.0
 */
typedef ACTAccountInfo = {
	/**
	 * The current Account Info's username, if it returns error code it will be `""` because it doesn't exist yet.
	 */
	var username:String;

	/**
	 * The current user's age (calculated using server time, not device time)
	 */
	var userAge:UInt16;

	/**
	 * Whether or not you've told the server to receive ads or not.
	 */
	var receiveAds:Bool;

	/**
	 * Whether or not this account's mii is a male or a female.
	 */
	var male:Bool;

	/**
	 * The current mii name.
	 */
	var miiName:String;

	/**
	 * Current Country Name. EG: FR, US, JP.
	 */
	var countryName:String;

	/**
	 * Current Principal ID.
	 * 
	 * @see https://www.3dbrew.org/wiki/Principal_ID
	 */
	var principalID:UInt32;

	/**
	 * The current birth date as `DD/MM/YYYY`.
	 * 
	 * Note: If using `pnid` and no date is specified, it returns `1/1/1990`.
	 */
	var birthDate:String;

	/**
	 * The URL Path to the image of your mii.
	 */
	var miiImageURL:String;
}

/**
 * ACT (Account) Services.
 * 
 * @since 1.4.0
 */
@:cppInclude('haxe3ds_Utils.h')
class ACT {
	static function getInfo(i:Int):ACTAccountInfo {
		untyped __cpp__('
			u16 userAge;
			bool ads;
			char cn[3];
			AccountInfo info;
			char url[257];

			#define actInfo(var, type) ACT_GetAccountInfo(&var, sizeof(var), {0}, type)
			actInfo(userAge, INFO_TYPE_AGE);
			actInfo(ads, INFO_TYPE_IS_ENABLED_RECEIVE_ADS);
			actInfo(cn, INFO_TYPE_COUNTRY_NAME);
			actInfo(info, INFO_TYPE_ACCOUNT_INFO);
			actInfo(url, INFO_TYPE_MII_IMAGE_URL);
			#undef actInfo

			char str[11];
			snprintf(str, 11, "%u/%u/%u", info.birthDate.day, info.birthDate.month, info.birthDate.year);
		', i);

		return {
			username: untyped __cpp__('info.accountId'),
			userAge: untyped __cpp__('userAge'),
			receiveAds: untyped __cpp__('ads'),
			male: untyped __cpp__('!info.mii.miiData.mii_details.sex'),
			miiName: untyped __cpp__('u16ToString(info.screenName)'),
			countryName: untyped __cpp__('String(reinterpret_cast<char*>(cn))'),
			principalID: untyped __cpp__('info.principalId'),
			birthDate: untyped __cpp__('String(reinterpret_cast<char*>(str))'),
			miiImageURL: untyped __cpp__('String(url)'),
		};
	}

	/**
	 * The total count of accounts the console has.
	 */
	public static var numAccount(get, null):UInt8;
	static function get_numAccount():UInt8 {
		untyped __cpp__('
			u8 res;
			ACT_GetCommonInfo(&res, 1, INFO_TYPE_COMMON_NUM_ACCOUNTS);
		');
		return untyped __cpp__('res');
	}

	/**
	 * The current account slot the console is using.
	 */
	public static var currentAccountSlot(get, null):UInt8;
	static function get_currentAccountSlot():UInt8 {
		untyped __cpp__('
			u8 res;
			ACT_GetCommonInfo(&res, 1, INFO_TYPE_COMMON_CURRENT_ACCOUNT_SLOT);
		');
		return untyped __cpp__('res');
	}

	/**
	 * NetworkTimeDifference: Difference between server time and UTC device time (in nanoseconds) 
	 */
	public static var networkTimeDiff(get, null):NanoTime;
	static function get_networkTimeDiff():NanoTime {
		untyped __cpp__('
			u64 res;
			ACT_GetCommonInfo(&res,	8, INFO_TYPE_COMMON_NETWORK_TIME_DIFF);
		');
		return untyped __cpp__('res');
	}

	/**
	 * Nintendo Network ID User Account's Info.
	 */
	public static var nnid(get, null):ACTAccountInfo;
	static function get_nnid():ACTAccountInfo {
		return getInfo(1); // 1 indicates account is using nnid
	}

	/**
	 * Pretendo Network ID User Account's Info.
	 */
	public static var pnid(get, null):ACTAccountInfo;
	static function get_pnid():ACTAccountInfo {
		return getInfo(3); // 3 indicates account is using pnid
	}

	/**
	 * Initializes ACT services and sets up other variables.
	 */
	public static function init():Result {
		return untyped __cpp__('actInit(false)');
	}

	/**
	 * Checks if an account from Nintendo or Pretendo is linked to the console's account.
	 * @param isPretendo If you want it to check if it's from pretendo or not.
	 * @return true if logged in (as if length of `username` is *not* 0), false if account is null or equals to 0.
	 */
	public static function isConnected(isPretendo:Bool = true):Bool {
		final account:Null<ACTAccountInfo> = isPretendo ? pnid : nnid;
		if (account == null) return false;
		return account.username.length != 0;
	}

	/**
	 * Exits AC service
	 */
	@:native("actExit")
	public static function exit() {}
}