package haxe3ds.services;

import haxe3ds.Types.Result;
import cxx.num.UInt16;
import cxx.num.UInt32;

typedef ACProxy = {
    /**
     * Whetever or not the proxy is enabled or not.
     */
    var enable:Bool;

    /**
     * Host name
     */
    var host:String;

    /**
     * Port used
     */
    var port:UInt16;

    /**
     * The current username for this proxy.
     */
    var username:String;

    /**
     * The password for this proxy.
     */
    var password:String;
}

/**
 * AC service.
 */
@:cppInclude("haxe3ds_services_GFX.h")
class AC {
    /**
     * `(AC:U)` Current Wifi Status.
     * 
     * List of Point Types:
     * - `0`:  No access point/none allowed.
     * - `1`:  Slot 1 in System Settings.
     * - `2`:  Slot 2 in System Settings.
     * - `4`:  Slot 3 in System Settings.
     * - `16`: Nintendo Zone AP.
     * 
     * If none of the value in `wifiStatus` match, it's likely intended to be a error code.
     * 
     * Lists of error codes from this variable:
     * - `0xE0A09D2E (3768622382)`: Happens if the hardware wifi switch is set to off or when the system is connecting to the Internet.
     * 
     * @see https://www.3dbrew.org/wiki/ACU:GetWifiStatus
     */
    public static var wifiStatus(default, null):UInt32 = 0;

    /**
     * `(AC:U)` Whetever or not the 3DS is connected to the Internet.
     * 
     * This is automatically be set when `AC.init` is called,
     * Then it also calls `ACU_GetStatus` and checks if output is `3` (which typically means "connected"),
     * if it's not connected then it will return `1`
     */
    public static var connected(default, null):Bool = false;

    /**
     * `(AC:U)` The SSID as a string called from `ACU_GetSSID`.
     * 
     * For some reason returns `66` for my console, or is it just me?
     * 
     * @since 1.3.0 (now uses `ACI_GetNetworkWirelessEssidSecuritySsid`)
     */
    public static var ssid(default, null):String = "";

    /**
     * `(AC:U)` The proxy settings set from `AC.init`
     */
    public static var proxy(default, null):ACProxy = {
        enable: false,
        host: "",
        port: 0,
        username: "",
        password: ""
    };

    /**
     * Initializes AC and sets up everything.
     */
    public static function init() {
        untyped __cpp__('
            acInit();
            
            Result r = 0;
            if (R_FAILED(r = ACU_GetWifiStatus(&wifiStatus))) {
                wifiStatus = r;
            }

            u16 f = 0;
            u32 e = 0;
            char s;
            bool b = false;

            ACU_GetStatus(&e);
            connected = e == 3;

            ACI_GetNetworkWirelessEssidSecuritySsid(&s);
            ssid = std::to_string(s);

            ACU_GetProxyEnable(&b);
            proxy->enable = b;

            ACU_GetProxyHost(&s);
            proxy->host = std::to_string(s);

            ACU_GetProxyPort(&f);
            proxy->port = f;

            ACU_GetProxyUserName(&s);
            proxy->username = s;

            ACU_GetProxyPassword(&s);
            proxy->password = s;
        ');
    }

    /**
     * `(AC:I)` Selects the WiFi configuration slot for further AC:I operations.
     * @param slot WiFi slot (0, 1 or 2).
     */
    @:native("ACI_LoadNetworkSetting")
    public static function loadNetworkSetting(slot:UInt32):Result {
        return 0;
    }

    /**
     * Exits AC
     */
    @:native("acExit")
    public static function exit() {}
}