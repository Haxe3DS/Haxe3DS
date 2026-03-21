package haxe3ds.services;

import cpp.UInt16;
import haxe3ds.types.Result;

/**
 * Media Type for File System.
 * 
 * @since 1.6.0
 */
enum abstract FSMediaType(Int) {
	/**
	 * NAND
	 */
	var NAND = 0;

	/**
	 * SD Card
	 */
	var SD = 1;

	/**
	 * Game Card (Although rarely used.)
	 */
	var CARD = 2;
}

/**
 * File System Service.
 * 
 * This service includes features such as mounting a save, getting and setting the play coins, and SDMC utility!
 * 
 * @since 1.1.0
 */
@:cppFileCode('
// https://www.3dbrew.org/wiki/RomFS#Hash_Table_Structure
int getHashTableLength(int numEntries) {
	int count = numEntries;
	if (count < 3) {
		count = 3;
	} else if (count < 19) {
		count |= 1;
	} else {
		while (count % 2 == 0 
			|| count % 3 == 0 
			|| count % 5 == 0 
			|| count % 7 == 0 
			|| count % 11 == 0 
			|| count % 13 == 0 
			|| count % 17 == 0) {
			count++;
		}
	}
	return count;
}')
@:headerCode('
#include "haxe3ds_Utils.h"

namespace FSD {
FS_Archive sdmcRoot;
FS_Archive get_sdmcRoot() {
	if (sdmcRoot == 0) {
		FSUSER_OpenArchive(&sdmcRoot, ARCHIVE_SDMC, fsMakePath(PATH_EMPTY, ""));
	}
	return sdmcRoot;
}
}
')
class FS {
	/**
	 * Variable property that gets whether an SD card is detected.
	 * 
	 * If the SDMC is found and detected, it returns `true`, else `false`.
	 */
	public static var isSDMCDetected(get, null):Bool;
	static function get_isSDMCDetected():Bool {
		return untyped __cpp__('API_GETTER(bool, FSUSER_IsSdmcDetected, 0)');
	}

	/**
	 * Gets whether the SD card is writable.
	 * 
	 * If the SDMC can be written, it returns `true`, else `false`
	 */
	public static var isSDMCWritable(get, null):Bool;
	static function get_isSDMCWritable():Bool {
		return untyped __cpp__('API_GETTER(bool, FSUSER_IsSdmcWritable, 0)');
	}

	#if IS_CIA
	/**
	 * Mounts a save data from the console, will format the whole save data in this app if something has gone wrong!
	 * 
	 * This has PROPER error handling mounts, if errors then formats, check fail, if not try again, if failed returns false, else returns true.
	 * 
	 * *Note*: This is practically not possible if it's a 3DSX app, CIA would defidently work well.
	 * 
	 * @param partition Partition of the save data to use, Leave default for `ext`
	 * @param files Files to actually store in the save data (will be calculated by `getHashTableLength`).
	 * @param dirs Same as `files`.
	 * @return Result code of Whether something from the services went wrong.
	 * @since 1.3.0
	 */
	public static function mountSaveData(partition:String = "ext", files:Int = 1, dirs:Int = 1):Result {
		var res:Result = 0;

		untyped __cpp__('
			const char* p = partition.c_str();

			FS_Path path = fsMakePath(PATH_EMPTY, "");
			if ((res = archiveMount(ARCHIVE_SAVEDATA, path, p)) == 0xC8A04554) { // save format error
				if R_FAILED(
					res = FSUSER_FormatSaveData(ARCHIVE_SAVEDATA, path, 0x200, dirs, files, getHashTableLength(dirs), getHashTableLength(files), false)
				) return res;

				res = archiveMount(ARCHIVE_SAVEDATA, path, p);
			}
		');

		return res;
	}

	/**
	 * Flushes and Commits the save data to this software, this will OVERWRITE the old data and can only be restored if the user has it saved in his backups.
	 * 
	 * *Note*: Doesn't seem to be flushed in 3DS but can in AZAHAR?
	 * 
	 * @param partition Partition of the save data to use, Leave default for `ext`
	 * @return Result code of Whether something from the services went wrong.
	 * @since 1.3.0
	 */
	public static function flushAndCommit(partition:String = "ext"):Result {
		return untyped __cpp__('archiveCommitSaveData(partition.c_str())');
	}
	#end

	/**
	 * Variable for the concurrent Play Coins in your system found by `/gamecoin.dat`.
	 * 
	 * Minimum 0, Maximum 300.
	 * 
	 * Note: If any of the FS API failed, `-1` will be returned!
	 * 
	 * @since 1.3.0
	 */
	public static var playCoins(get, set):UInt16;
	
	static function get_playCoins():UInt16 {
		var out:UInt16 = -1;
		untyped __cpp__('
			FS_Archive archive;
			u32 path[3] = {MEDIATYPE_NAND, 0xF000000B, 0x00048000};
			if (R_FAILED(FSUSER_OpenArchive(&archive, ARCHIVE_SHARED_EXTDATA, (FS_Path){PATH_BINARY, 0xC, path}))) {
				goto end1;
			}

			Handle fileHandle;
			if (R_FAILED(FSUSER_OpenFile(&fileHandle, archive, fsMakePath(PATH_UTF16, u"/gamecoin.dat"), FS_OPEN_READ | FS_OPEN_WRITE, FS_ATTRIBUTE_ARCHIVE))) {
				goto end2;
			}

			u32 _;
			FSFILE_Read(fileHandle, &_, 4, &out, sizeof(out));

			FSFILE_Close(fileHandle);
			end2:
			FSUSER_CloseArchive(archive);
			end1:
		');
		return out;
	}
	
	static function set_playCoins(playCoins):UInt16 {
		playCoins = playCoins > 300 ? 300 : playCoins < 0 ? 0 : playCoins;

		untyped __cpp__('
			FS_Archive archive;
			u32 path[3] = {MEDIATYPE_NAND, 0xF000000B, 0x00048000};
			u8 coinBytes[2] = {(u8)(playCoins & 0xFF), (u8)((playCoins >> 8) & 0xFF)};
			bool fail = true;
			if (R_FAILED(FSUSER_OpenArchive(&archive, ARCHIVE_SHARED_EXTDATA, (FS_Path){PATH_BINARY, 0xC, path}))) {
				goto end1;
			}

			Handle fileHandle;
			if (R_FAILED(FSUSER_OpenFile(&fileHandle, archive, fsMakePath(PATH_UTF16, u"/gamecoin.dat"), FS_OPEN_READ | FS_OPEN_WRITE, FS_ATTRIBUTE_ARCHIVE))) {
				goto end2;
			}

			u32 _;
			fail = R_FAILED(FSFILE_Write(fileHandle, &_, 4, coinBytes, sizeof(coinBytes), FS_WRITE_FLUSH));

			FSFILE_Close(fileHandle);
			end2:
			FSUSER_CloseArchive(archive);
			end1:

			if (fail) {
				return -1;
			}
		');
		return playCoins;
	}

	/**
	 * Deletes a file located in SDMC
	 * @param path Path to delete.
	 * @return Result of Whether the function succeded or not.
	 * @since 1.4.0
	 */
	public static function deleteFile(path:String):Result {
		return untyped __cpp__('FSUSER_DeleteFile(FSD::get_sdmcRoot(), fsMakePath(PATH_ASCII, path.c_str()))');
	}

	/**
	 * Renames a file in SDMC from `source` to `destination`.
	 * 
	 * Possible Result Code(s):
	 * - `0xC82047EF` - File's source does not exist, destination already exist or it's source/destination had illegal characters.
	 * 
	 * @param source The source file to find and rename.
	 * @param destination The new file name to use.
	 * @return Result of Whether the function succeded or not.
	 */
	public static function renameFile(source:String, destination:String):Result {
		return untyped __cpp__('FSUSER_RenameFile(FSD::get_sdmcRoot(), fsMakePath(PATH_ASCII, source.c_str()), FSD::get_sdmcRoot(), fsMakePath(PATH_ASCII, destination.c_str()))');
	}

	/**
	 * Deletes a directory or even recursively deletes a directory!
	 * @param source Source Directory to Use.
	 * @param recursive Whether or not should recursively delete the directory.
	 * @return Result of Whether the function succeded or not.
	 * @since 1.5.0
	 */
	public static function deleteDir(source:String, recursive:Bool = false):Result {
		untyped __cpp__('FS_Path p = fsMakePath(PATH_ASCII, source.c_str())');
		return untyped __cpp__('recursive ? FSUSER_DeleteDirectoryRecursively(FSD::get_sdmcRoot(), p) : FSUSER_DeleteDirectory(FSD::get_sdmcRoot(), p)');
	}

	/**
	 * The current CTR Root Path in `sdmc` with this format: `/Nintendo 3DS/<id0>/<id1>`
	 * 
	 * ID0 and ID1 are randomly generated Base16 codes with the length of 32, example: `0d8f84f6c9a6af5ab0f61111e952aa9d`.
	 * 
	 * @since 1.6.0
	 */
	public static var ctrRootPath(default, null):String = "";
	static function get_ctrRootPath():String {
		untyped __cpp__('
			u16 root[256] = { 0};
			FSUSER_GetSdmcCtrRootPath((u8*)root, 512)
		');
		return untyped __cpp__('u16ToString(root)');
	}

	/**
	 * Closes SDMC Archive and Exits FS.
	 */
	public static function exit() {
		untyped __cpp__('
			FSUSER_CloseArchive(FSD::get_sdmcRoot());
			fsExit()
		');
	}
}

/**
 * The Application Title Metadata.
 * @since 1.6.0
 */
typedef FSSMDHAppTitle = {
	/**
	 * The short description (length = 0x40) for this title.
	 */
	var shortDescription:String;

	/**
	 * The long description (length = 0x80) for this title.
	 */
	var longDescription:String;

	/**
	 * The Publisher (length = 0x40) for this title.
	 */
	var publisher:String;
}

/**
 * App Title's Game Rating Flag depending by region's bit.
 * @since 1.6.0
 */
enum FSSMDHAppGameRatingsFlag {
	/**
	 * CERO (Japan)
	 */
	CERO;

	/**
	 * ESRB (USA)
	 */
	ESRB;

	/**
	 * USK (German)
	 */
	USK;

	/**
	 * PEGI GEN (Europe)
	 */
	PEGI_GEN;

	/**
	 * PEGI PRT (Portugal)
	 */
	PEGI_PRT;

	/**
	 * PEGI BBFC (England)
	 */
	PEGI_BBFC;

	/**
	 * COB (Australia)
	 */
	COB;

	/**
	 * GRB (South Korea)
	 */
	GRB;

	/**
	 * CGSRR (Taiwan)
	 */
	CGSRR;
}

/**
 * App Title's Region Lockout Flag depending by bitmask value.
 * @since 1.6.0
 */
enum FSSMDHAppRegionLockout {
	/**
	 * Japan
	 * 
	 * `BITMASK 0x01`
	 */
	JAPAN;

	/**
	 * North America
	 * 
	 * `BITMASK 0x02`
	 */
	NORTH_AMERICA;

	/**
	 * Europe
	 * 
	 * `BITMASK 0x04`
	 */
	EUROPE;

	/**
	 * Australia
	 * 
	 * `BITMASK 0x08`
	 */
	AUSTRALIA;

	/**
	 * China
	 * 
	 * `BITMASK 0x10`
	 */
	CHINA;

	/**
	 * Korea
	 * 
	 * `BITMASK 0x20`
	 */
	KOREA;

	/**
	 * Taiwan
	 * 
	 * `BITMASK 0x40`
	 */
	TAIWAN;
}

/**
 * @since 1.6.0
 * The Title's App Settings.
 */
typedef FSSMDHAppSettings = {
	/**
	 * Title's Game Ratings that can be used for Parental Controls.
	 */
	var gameRatings:Array<FSSMDHAppGameRatingsFlag>;

	/**
	 * Title's Region Lockout that's restricted by Region.
	 */
	var regionLock:Array<FSSMDHAppRegionLockout>;
};

/**
 * SMDH Metadata for a specific title.
 * 
 * TODO: Finish these.
 * @since 1.6.0
 */
@:cppFileCode('
#include "haxe3ds_Utils.h"

struct SMDH {
	struct Header {
		u32 magic;
		u16 version;
		u16 reserved;
	};

	struct ApplicationTitle {
		u16 shortDescription[0x40];
		u16 longDescription[0x80];
		u16 publisher[0x40];
	};

	struct Settings {
		u8 gameRatings[0x10];
		u32 regionLock;
		u32 matchmaker_id;
		u64 matchmaker_id_bit;
		u32 flags;
		u16 eulaVersion;
		u16 reserved;
		u32 defaultFrame;
		u32 cecId;
	};

	Header header;
	ApplicationTitle applicationTitles[16];
	Settings settings;
	u64 reserved;
	u8 smallIconData[0x480];
	u16 bigIconData[0x900];
};
')
class FSSMDH {
	/**
	 * Result by any of the File System API called.
	 */
	public var result(default, null):Result = 0;

	/**
	 * Whether or not this SMDH metadata is valid.
	 */
	public var valid(default, null):Bool = false;

	/**
	 * An array for application titles.
	 *
	 * ```
	 * INDEX | Language
	 * ----------------
	 * 0     | Japanese
	 * 1     | English
	 * 2     | French
	 * 3     | German
	 * 4     | Italian
	 * 5     | Spanish
	 * 6     | Simplified Chinese
	 * 7     | Korean
	 * 8     | Dutch
	 * 9     | Portuguese
	 * 10    | Russian
	 * 11    | Traditional Chinese
	 * ```
	 */
	public var applicationTitles(default, null):Array<FSSMDHAppTitle> = [];

	/**
	 * App Settings that is only used by HOME Menu.
	 */
	public var appSettings(default, null):FSSMDHAppSettings = {
		gameRatings: [],
		regionLock: []
	};

	/**
	 * Constructor for the SMDH Metadata.
	 * @param highTID The HIGH Title ID to use.
	 * @param lowTID The LOW Title ID to use.
	 * @param media The mediatype for the title.
	 */
	public function new(highTID:Int, lowTID:Int, media:FSMediaType) {
		untyped __cpp__('
			u32 archPath[] = {lowTID, highTID, (FS_MediaType)media, 0x0};
			static const u32 filePath[] = {0x0, 0x0, 0x2, 0x6E6F6369, 0x0};

			SMDH smdhData;
			FS_Path binArchPath = {PATH_BINARY, 0x10, archPath};
			FS_Path binFilePath = {PATH_BINARY, 0x14, filePath};
			Handle file;
			u32 read;

			#define RETURN_IF_FAILED(x) {\\
				Result y = x; \\
				if (R_FAILED(y)) { \\
					this->result = y; \\
					if (file) FSUSER_CloseArchive(file); \\
					return; \\
				} \\
			} \\

			RETURN_IF_FAILED(FSUSER_OpenFileDirectly(&file, ARCHIVE_SAVEDATA_AND_CONTENT, binArchPath, binFilePath, FS_OPEN_READ, 0));
			RETURN_IF_FAILED(FSFILE_Read(file, &read, 0, &smdhData, sizeof(SMDH)));
			FSUSER_CloseArchive(file);

			if (!(valid = (smdhData.header.magic == 0x48444D53))) {
				return;
			}

			#undef RETURN_IF_FAILED
		');

		for (i in 0...12) {
			applicationTitles.push({
				shortDescription: untyped __cpp__('u16ToString(smdhData.applicationTitles[{0}].shortDescription)', i),
				longDescription: untyped __cpp__('u16ToString(smdhData.applicationTitles[{0}].longDescription)', i),
				publisher: untyped __cpp__('u16ToString(smdhData.applicationTitles[{0}].publisher)', i)
			});
		}

		final flags:Array<FSSMDHAppGameRatingsFlag> = [CERO, ESRB, USK, PEGI_GEN, PEGI_PRT, PEGI_BBFC, COB, GRB, CGSRR];
		for (i in 0...12) {
			if (i == 2 || i == 5) continue; // reserved flag

			if (untyped __cpp__('smdhData.settings.gameRatings[{0}]', i)) {
				var j:Int = i;
				if (i > 1) j--;
				if (i > 4) j--;
				this.appSettings.gameRatings.push(flags[j]);
			}
		}

		final Lflags:Array<FSSMDHAppRegionLockout> = [JAPAN, NORTH_AMERICA, EUROPE, AUSTRALIA, CHINA, KOREA, TAIWAN];
		for (i in 0...7) {
			if (untyped __cpp__('BIT({0}) & smdhData.settings.regionLock', i)) {
				this.appSettings.regionLock.push(Lflags[i]);
			}
		}
	}
}