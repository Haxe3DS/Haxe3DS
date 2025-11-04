package haxe3ds.applet;

import haxe.Exception;
import haxe3ds.services.CFGU;

using StringTools;

/**
 * Class for the Internet Browser API.
 * 
 * @since 1.5.0
 */
@:cppInclude("haxe3ds_services_GFX.h")
@:cppInclude("cstring")
class WebBrowser {
	/**
	 * Maximum number of characters in a URL.
	 */
	public static var MAX_LENGTH(default, null):Int = 1024;

	/**
	 * Checks if the Internet Browser is restricted by Parental Controls, this also calls `CFGU` so hope you've initialized that.
	 * @return `true` if it's restricted, `false` otherwise.
	 */
	public static function isRestricted():Bool {
		final config:CFGUParental = CFGU.getParentalControlInfo();
		if (config == null) return false;
		return config.restriction.toString().contains("INTERNET_BROWSER");
	}

	/**
	 * Checks if the URL is valid and is in a size lower than `MAX_LENGTH`.
	 * @param url The URL to check for validation.
	 * @return `true` if url is valid, `false` otherwise.
	 */
	public static function isURLValid(url:String):Bool {
		if (
			url.length == 0 ||
			url.length > MAX_LENGTH ||
			!~/^(https?):\/\/([a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)*)(:[0-9]+)?(\/[^\s]*)?$/.match(url) ||
			url.contains("..") || url.contains("\\")
		) return false;
	
		try {
			final host:String = url.split("://")[1].split("/")[0];
			if (host.length == 0 || !host.contains(".")) return false;
		} catch(e:Exception) {
			return false;
		}
	
		return true;
	}

	/**
	 * Launches the URL, and by that i mean it launches the applet "SPIDER" or "SKATER", this also calls `isURLValid` and skips if it it's invalid.
	 * @param url The URL to launch.
	 */
	public static function launchURL(url:String) {
		if (!isURLValid(url)) return;

		untyped __cpp__('
			size_t urlLen = url.size() + 1, bSize = urlLen + 1;
			u8* buffer = (u8*)malloc(bSize);
			if (!buffer) return;
			memcpy(buffer, url.c_str(), urlLen);
			buffer[urlLen] = 0;
			aptLaunchSystemApplet(APPID_WEB, buffer, bSize, 0);
			free(buffer);
		');
	}
}