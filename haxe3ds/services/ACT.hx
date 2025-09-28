package haxe3ds.services;

import cxx.num.UInt16;
import cxx.num.UInt64;
import cxx.num.UInt8;

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
     * Whetever or not you've told the server to receive ads or not.
     */
    var receiveAds:Bool;

    /**
     * Whetever or not this account's mii is a male or a female.
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
}

/**
 * ACT (Account) Services.
 * 
 * @since 1.4.0
 */
@:cppFileCode('
#include <3ds.h>
#include "haxe3ds_Utils.h"
')
class ACT {
    /**
     * The total count of accounts the console has.
     */
    public static var numAccount(default, null):UInt8 = 0;

    /**
     * The current account slot the console is using.
     */
    public static var currentAccountSlot(default, null):UInt8 = 0;

    /**
     * NetworkTimeDifference: Difference between server time and UTC device time (in nanoseconds) 
     */
    public static var networkTimeDiff(default, null):UInt64 = 0;

    /**
     * Nintendo Network ID User Account's Info.
     */
    public static var nnid(default, null):ACTAccountInfo = {
        username: "",
        userAge: 0,
        receiveAds: false,
        male: false,
        miiName: "",
        countryName: "",
        principalID: 0,
        birthDate: ""
    };

    /**
     * Pretendo Network ID User Account's Info.
     */
    public static var pnid(default, null):ACTAccountInfo = {
        username: "",
        userAge: 0,
        receiveAds: false,
        male: false,
        miiName: "",
        countryName: "",
        principalID: 0,
        birthDate: ""
    };

    /**
     * Initializes ACT services and sets up other variables.
     */
    public static function init() {
        untyped __cpp__('
            actInit(false);

            ACT_GetCommonInfo(&numAccount,         1, INFO_TYPE_COMMON_NUM_ACCOUNTS);
            ACT_GetCommonInfo(&currentAccountSlot, 1, INFO_TYPE_COMMON_CURRENT_ACCOUNT_SLOT);
            ACT_GetCommonInfo(&networkTimeDiff,    8, INFO_TYPE_COMMON_NETWORK_TIME_DIFF);

            using namespace std;
            auto nidU = nnid, pidU = pnid;

            int j[2] = {1, 3};
            typedef char country[3];
            for (int i = 0; i < 2; i++) {
                u16           userAge;
                bool          ads;
                country       cn;
                AccountInfo   info;

                int k = j[i];
                ACT_GetAccountInfo(&userAge,  2, k, INFO_TYPE_AGE);
                ACT_GetAccountInfo(&ads,      1, k, INFO_TYPE_IS_ENABLED_RECEIVE_ADS);
                ACT_GetAccountInfo(&cn,       3, k, INFO_TYPE_COUNTRY_NAME);
                ACT_GetAccountInfo(&info,   160, k, INFO_TYPE_ACCOUNT_INFO);

                char str[11];
				snprintf(str, 11, "%u/%u/%u", info.birthDate.day, info.birthDate.month, info.birthDate.year);

                auto set = i == 0 ? nidU : pidU;
                set->username    = string(info.accountId);
                set->userAge     = userAge;
                set->receiveAds  = ads;
                set->male        = !info.mii.miiData.mii_details.sex;
                set->miiName     = u16ToString(info.screenName, 11);
                set->countryName = string(reinterpret_cast<char*>(cn));
                set->principalID = info.principalId;
                set->birthDate   = string(str);
            }
        ');

        nnid = untyped __cpp__('nidU');
        pnid = untyped __cpp__('pidU');
    }

    /**
     * Exits AC service
     */
    @:native("actExit")
    public static function exit() {}
}