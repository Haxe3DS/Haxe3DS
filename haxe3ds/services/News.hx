package haxe3ds.services;

import cpp.UInt8;
import cpp.UInt64;
import cpp.UInt32;
import sys.FileSystem;
import sys.io.File;
import haxe3ds.types.OutOfBoundsException;
import haxe3ds.types.Result;

using StringTools;

/**
 * The Notification Header.
 * 
 * @since 1.3.0
 */
typedef NEWSHeader = {
	/**
	 * Whether or not the data's fully set or not.
	 * 
	 * If this value if `false`, this will cause the news to say this header is invalid and will ignore this.
	 */
	var dataSet:Bool;

	/**
	 * Whether or not the notification is unread by the News Applet.
	 * 
	 * If it's still unread, it would show a `blue` or `green` circle light.
	 */
	var unread:Bool;

	/**
	 * Whether or not the image is a JPEG or not.
	 */
	var enableJPEG:Bool;

	/**
	 * Whether or not the notification is a SpotPass or a StreetPass using CECD.
	 * 
	 * Note: If set to `true`, shows a "Opt out of notifications for this software" in the Notification Applet.
	 */
	var isSpotPass:Bool;

	/**
	 * Whether or not this notification was opted out.
	 * 
	 * This could only be found if notification has `isSpotPass` to `true` or the app has it available.
	 */
	var isOptedOut:Bool;

	/**
	 * Notification Program ID Source (`0` if it's System Notifications) 
	 */
	var processID:UInt64;

	/**
	 * Specified by source app and later retrieved via APT to identify which notification, if any it was launched from.
	 */
	var jumpParam:UInt64;

	/**
	 * Milliseconds since January 1, 2000.
	 */
	var time:UInt64;

	/**
	 * UTF-16 to String Converted for the notification title.
	 */
	var title:String;

	/**
	 * Whether or not this has browser included for this notification.
	 * @since 1.6.0
	 */
	var browser:Bool;
}

/**
 * Built-in Sets of Patters that the NEWS Service has.
 * @since 1.8.0
 */
enum abstract NewsLampPattern(UInt8) {
	/**
	 * BOSS Pattern, Flashes `CYAN`.
	 */
	var BOSS = 3;

	/**
	 * StreetPass Pattern, Flashes `GREEN` to act like you got a StreetPass Notification, If you really wanna trick someone into thinking they got a Free StreetPass, Well... It's up to you.
	 */
	var CEC = 5;

	/**
	 * Friend is Online, Flashes `ORANGE`.
	 */
	var FRIEND_ONLINE = 7;
}

/**
 * News (Notification Appleter) Service.
 * 
 * This requires [this libctru fork](https://github.com/Haxe3DS/libctru) to actually get most of it working,
 * if you do not have the custom libctru library installed, this will cause compiler errors just to get one working.
 * 
 * ### Result Codes:
 * - `0xC8804470` - News MPO image was not found and cannot be dumped.
 * - `0xD8E007F7` - Invalid handle, it's either `News` or `FS` that was not initialized.
 * - `0xD900182F` - Original libctru repo is a trainwreck that uses the wrong handle to get the value.
 * 
 * @see https://github.com/devkitPro/libctru/issues/587 `(0xD900182F)`
 * 
 * ### Information:
 * News stores a save data with files like `news.db`, `newsXXX.mpo` and `newsXXX.txt` where:
 * - `db`: The database.
 * - `mpo`: The image that will be displayed if it's available and valid.
 * - `txt`: The message body content that should be displayed.
 * 
 * 
 * News has a limit of 100 notifications, if you're adding another notification,
 * it will overwrite the oldest first, renaming all of them to comply with the new notification,
 * then add the new one there, you cannot get the oldest one back without having to
 * read the old news first then adding a notification the second.
 * 
 * #### You can do this following snippet as an example:
 * ```
 * var oldHeader = News.getHeader(News.totalNotifications);
 * var result = News.addNotification("Hello, World!", "Got the old header back");
 * 
 * if (result != null) { // success
 * 	trace(oldHeader); // do whatever you want with the old header
 * }
 * ```
 */
@:cppInclude("haxe3ds_Utils.h")
class News {
	/**
	 * Initializes NEWS.
	 */
	public static inline function init():Result {
		return untyped __cpp__('newsInit()');
	};

	/**
	 * Exits NEWS.
	 */
	public static inline function exit() {
		untyped __cpp__('newsExit');
	}

	/**
	 * Function that adds a new notification with the specified arguments provided.
	 * 
	 * This will do some file handling as in creating a file for the news title, description, and much more,
	 * this will also remove the oldest first if `News.totalNotifications > 100` to save space and make the notification applet
	 * not run slower than expected.
	 * 
	 * @param title Title to specify for how your notification should be. Maximum `0x40 (64)` in length.
	 * @param message Message body to say what new content or goofing you wanna use.  Maximum `0x1780 (6016)` in length.
	 * @param imagePath Path to the image to read and apply to the image on the top screen on the Notification Applet,
	 * this also sets the jpeg variable. Maximum `0xC800` bytes, this will skip if the image size is larger than the maximum amount.
	 * @return Result to indicate if something went wrong or not.
	 * @since 1.3.0
	 */
	public static function addNotification(title:String, message:String, imagePath:Null<String> = null):Result {
		untyped __cpp__("
			u16 OutTitle[0x40] = { 0};
			u16 OutMessage[0x1780] = { 0};

			u32 tsize = (u32)TRANSFER(title.c_str(), OutTitle);
			u32 msize = (u32)TRANSFER(message.c_str(), OutMessage);

			u64 size = 0;
			u8* image;
		");

		var jpeg = false;
		if (imagePath != null && FileSystem.exists(imagePath)) {
			var sz = FileSystem.stat(imagePath).size;
			if (sz < 0xC800) {
				jpeg = imagePath.endsWith(".jpg") || imagePath.endsWith(".jpeg");
				var bytes = File.getBytes(imagePath);
				untyped __cpp__('
					image = (u8*){0}->b->getBase();
					size = {1}
				', bytes, sz);
			}
		}

		return untyped __cpp__('NEWS_AddNotification(OutTitle, tsize, OutMessage, msize, image, size, {0})', jpeg);
	}

	/**
	 * Function that gets the header from the specified `newsID`.
	 * 
	 * This will have checks on `dataSet` validity, if the specified `newsID` is false, this will return `null`
	 * 
	 * @param newsID The specified valid news ID to use
	 * @return The header for this news, or `null` if failed.
	 * @since 1.3.0
	 */
	public static function getHeader(newsID:Int):Null<NEWSHeader> {
		untyped __cpp__('
			NotificationHeader h;
			RETURN_NULL_IF_FAILED(NEWS_GetNotificationHeader(newsID, &h));
		');

		return {
			dataSet:	untyped __cpp__('h.dataSet'),
			unread:	    untyped __cpp__('h.unread'),
			enableJPEG: untyped __cpp__('h.enableJPEG'),
			isSpotPass: untyped __cpp__('h.isSpotPass'),
			isOptedOut: untyped __cpp__('h.isOptedOut'),
			processID:  untyped __cpp__('h.processID'),
			jumpParam:  untyped __cpp__('h.jumpParam'),
			time:	    untyped __cpp__('h.time'),
			title:	    untyped __cpp__('u16ToString(h.title)'),
			browser:    untyped __cpp__('h.hasURL')
		}
	}

	/**
	 * Sets a header from the specified news ID and output.
	 * @param newsID ID of the current news.
	 * @param out Header Type-Definition to use.
	 * @return Result code to check if something went wrong.
	 * @since 1.3.0
	 */
	public static function setHeader(newsID:Int, out:NEWSHeader):Result {
		untyped __cpp__('
			NotificationHeader h;
			NEWS_GetNotificationHeader(newsID, &h);

			h.dataSet = out->__Field(String("dataSet"),hx::paccDynamic);
			h.unread = out->__Field(String("unread"),hx::paccDynamic);
			h.enableJPEG = out->__Field(String("enableJPEG"),hx::paccDynamic);
			h.isSpotPass = out->__Field(String("isSpotPass"),hx::paccDynamic);
			h.isOptedOut = out->__Field(String("isOptedOut"),hx::paccDynamic);
			h.processID = out->__Field(String("processID"),hx::paccDynamic);
			h.jumpParam = out->__Field(String("jumpParam"),hx::paccDynamic);
			h.hasURL = out->__Field(String("browser"),hx::paccDynamic);
			h.time = out->__Field(String("time"),hx::paccDynamic);

			String title = (String)(out->__Field(String("title"),hx::paccDynamic));
			TRANSFER(title.c_str(), h.title);
		');

		return untyped __cpp__('NEWS_SetNotificationHeader(newsID, &h)');
	}

	/**
	 * Dumps the MPO/JPEG image to `SDMC` from the specified news.
	 * 
	 * @param newsID News ID to Use.
	 * @param dumpDest Dump Path Destination to Use.
	 * @return Result code to check if something went wrong.
	 */
	public static function dumpImage(newsID:UInt32, dumpDest:String):Result {
		var ret:Result = 0;

		untyped __cpp__('
			u32 size;
			FILE* f;
			void* data = malloc(0x10000);

			ret = NEWS_GetNotificationImage(newsID, data, &size);
			if R_FAILED(ret) {
				goto fail;
			}

			if (!(f = fopen(dumpDest.c_str(), "wb"))) {
				ret = -1;
				goto fail;
			}

			fwrite(data, 1, size, f);
			fclose(f);

			fail:
			free(data);
		');

		return ret;
	}

	/**
	 * Function that flashes the 3DS's LEDs built into the News Service.
	 * 
	 * **WARNING: Using Out of Bound patterns can CAUSE A BRICK because of reading garbage data Out of Bounds**
	 * 
	 * @param lamp The lamp located in `NewsLampPattern` with specific sets of built-in ones.
	 * @return Result to indicate if something went wrong.
	 * @throws OutOfBoundsException Throws if Value was not in the Expected Range.
	 * @see https://www.3dbrew.org/wiki/NEWSS:SetInfoLEDPattern
	 * @since 1.8.0
	 */
	public static function flashLEDPattern(lamp:NewsLampPattern):Result {
		var i = cast lamp;
		if (i < 3 || i > 7) {
			throw new OutOfBoundsException('Expected Value BOSS - FRIEND_ONLINE, Instead got a Out of Bound Value: $i');
		}

		var res:Result = 0;
		untyped __cpp__('
			u32* cmdbuf = getThreadCommandBuffer();
			cmdbuf[0] = 0x000E0040;
			cmdbuf[1] = lamp;
			if (R_SUCCEEDED((res = svcSendSyncRequest(newsGetHandle(true))))) res = cmdbuf[1];
		');

		return res;
	}

	/**
	 * Variable property that gets current total notifications number.
	 * 
	 * This returns either `0-100`, depending on how many news are stored.
	 */
	public static var totalNotifications(get, null):UInt32;
	static function get_totalNotifications():UInt32 {
		return untyped __cpp__('API_GETTER(u32, NEWS_GetTotalNotifications, 0)');
	}
}