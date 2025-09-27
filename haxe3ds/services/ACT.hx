package haxe3ds.services;

import cxx.num.UInt16;
import cxx.num.UInt64;
import cxx.num.UInt8;

/**
 * ACT's Account Information.
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
     * Whetever or not this account has chosen "male". If not then it's a female.
     */
    var male:Bool;

    /**
     * The current mii name.
     * 
     * ### Note:
     * Currently returning raw string bytes.
     */
    var miiName:String;
}

/**
 * ACT (Account) Services
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
        miiName: ""
    };

    /**
     * Pretendo Network ID User Account's Info.
     */
    public static var pnid(default, null):ACTAccountInfo = {
        username: "",
        userAge: 0,
        receiveAds: false,
        male: false,
        miiName: ""
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
            for (int i = 0; i < 2; i++) {
                AccountId     numAcc;
                u16           userAge;
                bool          ads;
                bool          male;
                MiiScreenName mii;

                int k = j[i];
                ACT_GetAccountInfo(&numAcc,  17, k, INFO_TYPE_ACCOUNT_ID);
                ACT_GetAccountInfo(&userAge,  2, k, INFO_TYPE_AGE);
                ACT_GetAccountInfo(&ads,      1, k, INFO_TYPE_IS_ENABLED_RECEIVE_ADS);
                ACT_GetAccountInfo(&male,     1, k, INFO_TYPE_GENDER);
                ACT_GetAccountInfo(&mii,     11, k, INFO_TYPE_MII_NAME);

                auto set = i == 0 ? nidU : pidU;
                set->username   = std::string(numAcc);
                set->userAge    = userAge;
                set->receiveAds = ads;
                set->male       = male;
                set->miiName    = u16ToString(mii, 11);
            }
        ');

        nnid = untyped __cpp__('nidU');
        pnid = untyped __cpp__('pidU');
    }

    public static function exit() {
        untyped __cpp__('
            actExit()
        ');
    }
}