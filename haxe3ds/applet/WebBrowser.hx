package haxe3ds.applet;

import haxe3ds.types.Result;
import haxe3ds.services.CFG;

using StringTools;

/**
 * Class for the Internet Browser API.
 * 
 * @since 1.5.0
 */
@:cppInclude("cstring")
@:cppInclude("3ds.h")
class WebBrowser {
	/**
	 * Maximum number of characters in a URL.
	 */
	public static inline final MAX_LENGTH:Int = 1024;

	/**
	 * Function to Check if one of the Parental Controls's Restriction about Internet Browser is Restricted.
	 * 
	 * @return `true` if it's restricted or config is `null`, `false` otherwise.
	 */
	public static function isRestricted():Bool {
		final config:CFGParental = CFG.parentalControlsInfo;
		if (config == null) return true;
		return config.restriction.contains(INTERNET_BROWSER);
	}

	/**
	 * Checks the URL in 6 ways.
	 * 
	 * The ways that'll be checked for the URL is if the URL:
	 * - Is empty. (length == 0)
	 * - Is longer than `MAX_LENGTH`. (length > `MAX_LENGTH`)
	 * - Matches by the EReg Checking.
	 * - Contains either `..` or `\\`
	 * - Has a Value from Splitting `://` then at Index 1 then Splitting again but for `/` at index 0.
	 * - Finally Checks by the Split Variable.
	 * 
	 * If one of those checks passes, it returns `false`, else it returns `true`.
	 * 
	 * @param url The URL to check for validation.
	 * @return `true` if url is valid, `false` because if failed one of the tests above.
	 */
	public static function isURLValid(url:String):Bool {
		url = url.trim();

		if (
			url.length == 0 ||
			url.length > MAX_LENGTH ||
			!~/^(https?):\/\/([a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)*)(:[0-9]+)?(\/[^\s]*)?$/.match(url) ||
			url.contains("..") || url.contains("\\")
		) return false;
	
		try {
			final host:String = url.split("://")[1].split("/")[0];
			if (host.length == 0 || !host.contains(".")) return false;
		} catch(_) {
			return false;
		}
	
		return true;
	}

	/**
	 * Launches the URL, and by that i mean it launches the applet "SPIDER" or "SKATER", this also calls `isURLValid` and skips if it it's invalid.
	 * 
	 * This allocates memory depending by the length of the URL String, Copies the URL to Buffer and Launches `APPID_WEB`.
	 * 
	 * Possible Result Variables:
	 * - `0xD8A13FF5`: URL Provided is Invalid.
	 * - `0xD8613FF3`: Allocating Failed, Possible due to Out of Memory.
	 * 
	 * @param url The URL to launch.
	 * @return The result received, if something has failed you should see the Possible Result Variables.
	 */
	public static function launchURL(url:String):Result {
		if (!isURLValid(url)) {
			return untyped __cpp__('MAKERESULT(RL_PERMANENT, RS_INVALIDSTATE, RM_WEB_BROWSER, RD_INVALID_ADDRESS)');
		}

		untyped __cpp__('
			size_t urlLen = url.length + 1;
			u8* buffer = (u8*)malloc(urlLen);
			if (!buffer) return MAKERESULT(RL_PERMANENT, RS_OUTOFRESOURCE, RM_WEB_BROWSER, RD_OUT_OF_MEMORY);
			memcpy(buffer, url.c_str(), urlLen);
			buffer[urlLen-1] = 0;
			aptLaunchSystemApplet(APPID_WEB, buffer, urlLen, 0);
			free(buffer);
		');

		return 0;
	}
}