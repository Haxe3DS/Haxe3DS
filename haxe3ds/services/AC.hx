package haxe3ds.services;

import haxe3ds.Types.Result;
import cpp.UInt16;
import cpp.UInt32;

typedef ACProxy = {
	/**
	 * Whether or not the proxy is enabled or not.
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
 * 
 * Lists of error codes:
 * - `0xE0A09D2E (3768622382)`: Happens if the hardware wifi switch is set to off or when the system is connecting to the Internet, happens on variable `wifiStatus`.
 */
@:cppInclude("haxe3ds_Utils.h")
class AC {
	/**
	 * `(AC:U)` Current Wifi Status.
	 * 
	 * List of Point Types:
	 * - `0`: No access point/none allowed.
	 * - `1`: Slot 1 in System Settings.
	 * - `2`: Slot 2 in System Settings.
	 * - `4`: Slot 3 in System Settings.
	 * - `8`: Nintendo Wi-Fi USB Connector.
	 * - `16`: Nintendo Zone AP.
	 * - `32`: Wi-Fi Station.
	 * - `64`: FreeSpot.
	 * - `128`: Hotspot.
	 * - `256`: Application-specified temporary settings.
	 * 
	 * If none of the value in `wifiStatus` match, it's likely intended to be a error code.
	 * 
	 * @see https://www.3dbrew.org/wiki/ACU:GetWifiStatus
	 */
	public static var wifiStatus(get, null):UInt32 = 0;
	static function get_wifiStatus():UInt32 {
		return untyped __cpp__('API_GETTER(u32, ACU_GetWifiStatus, 0)');
	}

	/**
	 * `(AC:U)` Whether or not the 3DS is connected to the Internet.
	 * 
	 * This is automatically be set when `AC.init` is called,
	 * Then it also calls `ACU_GetStatus` and checks if output is `3` (which typically means "connected"),
	 * If it's not connected then it will return `1`
	 */
	public static var connected(get, null):Bool = false;
	static function get_connected():Bool {
		return untyped __cpp__('API_GETTER(u32, ACU_GetStatus, 1) == 3');
	}

	/**
	 * `(AC:U)` The SSID as a string called from `ACU_GetSSID`.
	 * 
	 * For some reason returns `66` for my console, or is it just me?
	 * 
	 * @since 1.3.0 (now uses `ACI_GetNetworkWirelessEssidSecuritySsid`)
	 */
	public static var ssid(get, null):Null<String>;
	static function get_ssid():Null<String> {
		untyped __cpp__('
			char s[32] = { 0};
			if (R_FAILED(ACI_GetNetworkWirelessEssidSecuritySsid(s))) return null();
		');

		return untyped __cpp__('String(s)');
	}

	/**
	 * `(AC:U)` The proxy settings set from `AC.init`
	 */
	public static var proxy(get, null):Null<ACProxy>;
	static function get_proxy():Null<ACProxy> {
		untyped __cpp__('
			char host[0x100], user[0x100], pass[0x100];
			if R_FAILED(ACU_GetProxyHost(host)) return null();
			if R_FAILED(ACU_GetProxyUserName(user)) return null();
			if R_FAILED(ACU_GetProxyPassword(pass)) return null();
		');

		return {
			enable: untyped __cpp__('API_GETTER(bool, ACU_GetProxyEnable, false)'),
			host: untyped __cpp__('String(host)'),
			port: untyped __cpp__('API_GETTER(bool, ACU_GetProxyPort, 0)'),
			username: untyped __cpp__('String(user)'),
			password: untyped __cpp__('String(pass)'),
		}
	}

	/**
	 * Initializes AC.
	 */
	public static function init():Result {
		return untyped __cpp__('acInit()');
	}

	/**
	 * `(AC:I)` Selects the WiFi configuration slot for further AC:I operations.
	 * @param slot WiFi slot (0, 1 or 2).
	 */
	public static function loadNetworkSetting(slot:UInt32):Result {
		return untyped __cpp__('ACI_LoadNetworkSetting(slot)');
	}

	/**
	 * Exits AC
	 */
	@:native("acExit")
	public static function exit() {}
}