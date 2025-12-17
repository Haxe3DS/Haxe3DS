package haxe3ds.services;

import haxe3ds.services.FS.FSSMDH;
import haxe3ds.services.FS.FSMediaType;
import haxe3ds.Types.Result;
import cxx.num.UInt64;

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
	 * 
	 * TODO: Fill data with actual versions.
	 */
	var version:String;

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
@:cppFileCode('
#include "haxe3ds_Utils.h"
')
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
			u64 tids[300] = {0};
			AM_TitleInfo infos[300] = {0};
			FS_MediaType t = (FS_MediaType)media;
			RETURN_NULL_IF_FAILED(AM_GetTitleList(&titleLen, t, 300, tids));
			RETURN_NULL_IF_FAILED(AM_GetTitleInfo(t, titleLen, tids, infos))
		');

		final contents:Map<UInt32, AMContentType> = [1 => ENCRYPTED, 2 => DISC, 4 => HASHED, 8 => CFM, 8192 => SHA1_HASH, 16384 => OPTIONAL, 32768 => SHARED];
		for (i in 0...titleLen) {
			untyped __cpp__('
				char product[16] = {0};
				AM_GetTitleProductCode(t, tids[i], product)
			');

			final filtered:Array<AMContentType> = [];
			for (num in contents.keys()) {
				if ((num & untyped __cpp__('infos[i].titleType')) != 0) {
					filtered.push(contents[num]);
				}
			}

			final titleID:UInt64 = untyped __cpp__('tids[i]');
			final smdh:FSSMDH = new FSSMDH(titleID >> 32, titleID & 0xFFFFFFFF, media);
			function get(data:Void->String):String {
				return smdh.valid ? data() : "???";
			}

			out.push({
				titleID: titleID,
				productCode: untyped __cpp__('product'),
				contentType: filtered,
				version: "", // fill those data later
				size: untyped __cpp__('infos[i].size'),
				title: get(() -> smdh.applicationTitles[1].shortDescription),
				description: get(() -> smdh.applicationTitles[1].longDescription),
				publisher: get(() -> smdh.applicationTitles[1].publisher)
			});
		}

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
	public static function toBlocks(size:Int):Int {
		return Std.int(size / 131072);
	}
}