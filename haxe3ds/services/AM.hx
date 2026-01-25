package haxe3ds.services;

import cpp.UInt16;
import haxe3ds.services.FS.FSSMDH;
import haxe3ds.services.FS.FSMediaType;
import haxe3ds.Types.Result;
import cpp.UInt32;
import cpp.UInt64;

/**
 * Special Content Types from this Application.
 */
enum AMContentType {
	/**
	 * Content Type is encypted.
	 * 
	 * `BIT 0`
	 */
	ENCRYPTED;

	/**
	 * Content Type is stored into a disc(?).
	 * 
	 * `BIT 1`
	 */
	DISC;

	/**
	 * Content Type is hashed(?).
	 * 
	 * `BIT 2`
	 */
	HASHED;

	/**
	 * ???
	 * 
	 * `BIT 3`
	 */
	CFM;

	/**
	 * Content Type is hashed by SHA1
	 * 
	 * `BIT 13`
	 */
	SHA1_HASH;

	/**
	 * Content Type is optional that's only set for non-contentindex-0 DLC contents
	 * 
	 * `BIT 14`
	 */
	OPTIONAL;

	/**
	 * Content Type is shared.
	 * 
	 * `BIT 15`
	 */
	SHARED;
}

/**
 * A Typedef for the Title and its information.
 */
typedef AMTitleInfo = {
	/**
	 * The Application's Title ID for this this.
	 */
	var titleID:UInt64;

	/**
	 * The Application's Size for this title.
	 */
	var size:UInt64;

	/**
	 * The Applicaition's Version for this title, Format: `%d.%d.%d`
	 */
	var version:String;

	/**
	 * The Application's Raw Version (As in u16 version).
	 * @since 1.7.0
	 */
	var rawVersion:UInt16;

	/**
	 * An array of The Application's Content Types for this title.
	 */
	var contentType:Array<AMContentType>;

	/**
	 * The Application's Product Code (length = 16) for this title.
	 */
	var productCode:String;

	/**
	 * The Application's "Title" for this title.
	 */
	var title:String;

	/**
	 * The Application's "Description" for this title.
	 */
	var description:String;

	/**
	 * The Application's "Publisher" for this title.
	 */
	var publisher:String;
};

/**
 * Application Manager Service, allowing to do some settings with the titles.
 * @since 1.6.0
 */
@:cppInclude("haxe3ds_Utils.h")
class AM {
	/**
	 * Initializes AM, allowing to do some Application Management stuff.
	 * @return Result
	 */
	public static function init():Result {
		return untyped __cpp__('amAppInit()');
	}

	/**
	 * Exits AM.
	 */
	public static function exit() {
		untyped __cpp__('amExit()');
	}

	/**
	 * Gets the Whole Title Infos by their media type.
	 * 
	 * Note:
	 * - You are required to call `FS.init`, not doing it will result in compiler errors.
	 * 
	 * @param media Mediatype to use for searching titles.
	 * @return Array of Title Infos, null if any of the function fails.
	 */
	public static function getTitleInfos(media:FSMediaType):Null<Array<AMTitleInfo>> {
		var out:Array<AMTitleInfo> = [];
		var titleLen:UInt32 = 0;

		untyped __cpp__('
			u64 tids[300] = { 0};
			AM_TitleInfo infos[300] = { 0};
			FS_MediaType t = (FS_MediaType)media;
			RETURN_NULL_IF_FAILED(AM_GetTitleList(&titleLen, t, 300, tids));
			RETURN_NULL_IF_FAILED(AM_GetTitleInfo(t, titleLen, tids, infos))
		');

		final contents:Map<UInt32, AMContentType> = [1 => ENCRYPTED, 2 => DISC, 4 => HASHED, 8 => CFM, 8192 => SHA1_HASH, 16384 => OPTIONAL, 32768 => SHARED];
		for (i in 0...titleLen) {
			untyped __cpp__('
				char product[16] = { 0};
				AM_TitleInfo inf = infos[{0}];
				AM_GetTitleProductCode(t, tids[{0}], product)
			', i);

			final raw:UInt16 = untyped __cpp__('inf.version');
			untyped __cpp__('
				char ver[10];
				sprintf(ver, "%d.%d.%d", (inf.version >> 10) & 0x3F, (inf.version >> 4) & 0x3F, inf.version & 0xF)
			'); // thx fbi

			final filtered:Array<AMContentType> = [];
			for (num => key in contents.keyValueIterator()) {
				if ((num & untyped __cpp__('inf.titleType')) != 0) {
					filtered.push(key);
				}
			}

			final titleID:UInt64 = untyped __cpp__('tids[i]');
			final smdh:FSSMDH = new FSSMDH(untyped __cpp__('titleID >> 32'), untyped __cpp__('titleID & 0xFFFFFFFF'), media);
			inline function get(data:Void->String):String {
				return smdh.valid ? data() : "???";
			}

			out.push({
				titleID: titleID,
				productCode: untyped __cpp__('product'),
				contentType: filtered,
				version: untyped __cpp__("ver"),
				rawVersion: raw,
				size: untyped __cpp__('inf.size'),
				title: get(() -> smdh.applicationTitles[1].shortDescription),
				description: get(() -> smdh.applicationTitles[1].longDescription),
				publisher: get(() -> smdh.applicationTitles[1].publisher)
			});
		}

		return out;
	}

	/**
	 * Retrieves the current Device ID, this is used for SOAP requests since SOAP DeviceID is in u64, lower is the Pevice ID, upper is the Platform ID
	 * @since 1.7.0
	 */
	public static var deviceID(get, null):UInt32;
	static function get_deviceID():UInt32 {
		var out:UInt32 = 0;
		untyped __cpp__('AM_GetDeviceId(0, &out)');
		return out;
	}

	/**
	 * Calculates any size and converts to blocks (1 block = 128kib), Equivelant to doing this function:
	 * ```
	 * Std.int(blocks / 131072);
	 * ```
	 * 
	 * @param size Size in Int you want to input.
	 * @return Output Blocks.
	 */
	public static inline function toBlocks(size:Int):Int {
		return Std.int(size / 131072);
	}
}