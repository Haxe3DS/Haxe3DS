package haxe3ds.services;

enum MediaType {
    NAND;
    SD;
    GAME_CARD;
}

/**
 * File System Service.
 * 
 * This service includes features such as mounting a save, getting and setting the play coins, and SDMC utility!
 * 
 * @since 1.1.0
 */
@:cppFileCode("
#include <3ds.h>

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
}
")
class FS {
    /**
     * Initializes FS.
     */
    public static function init() {
        untyped __cpp__('
            fsInit();
            FSUSER_IsSdmcDetected(&isSDMCDetected);
            FSUSER_IsSdmcWritable(&isSDMCWritable)
        ');
    }

    /**
     * Variable property that gets whether an SD card is detected.
     * 
     * If the SDMC is found and detected, it returns `true`, else `false`.
     */
    public static var isSDMCDetected(default, null):Bool = false;

    /**
     * Gets whether the SD card is writable.
     * 
     * If the SDMC can be written, it returns `true`, else `false`
     */
    public static var isSDMCWritable(default, null):Bool = false;

    /**
     * Mounts a save data from the console, will format the whole save data in this app if something has gone wrong!
     * 
     * This has PROPER error handling mounts, if errors then formats, check fail, if not try again, if failed returns false, else returns true.
     * 
     * *Note*: This is practically not possible if it's a 3DSX app, CIA would defidently work well.
     * 
     * *Note 2*: Doesn't seem to be written in 3DS but can in AZAHAR?
     * 
     * @param partition Partition of the save data to use, Leave default for `ext`
     * @param files Files to actually store in the save data (will be calculated by `getHashTableLength`).
     * @param dirs Same as `files`.
     * @return `true` if successfully mounted, `false` if FS has failed or mount has failed (shouldn't happen?)
     * @since 1.3.0
     */
    public static function mountSaveData(partition:String = "ext", files:Int = 1, dirs:Int = 1):Bool {
        untyped __cpp__('
            bool retry = false;
            const char* p = partition.c_str();
            int i = getHashTableLength(dirs), j = getHashTableLength(files);

            FS_Path path = fsMakePath(PATH_EMPTY, "");
            Result ret = archiveMount(ARCHIVE_SAVEDATA, path, p);
            if (ret == 0xC8A04554) { // save format error
                ret = FSUSER_FormatSaveData(ARCHIVE_SAVEDATA, path, 0x200, dirs, files, i, j, false);
                if (R_FAILED(ret)) {
                    return false;
                }

                retry = true;
            }

            if (retry) {
                if (R_FAILED(archiveMount(ARCHIVE_SAVEDATA, path, p))) {
                    return false;
                }
            }
        ');
        return true;
    }

    /**
     * Flushes and Commits the save data to this software, this will OVERWRITE the old data and can only be restored if the user has it saved in his backups.
     * @param partition Partition of the save data to use, Leave default for `ext`
     * @return `true` if success, `false` if FS has failed or partition path doesn't exist.
     * @since 1.3.0
     */
    public static function flushAndCommit(partition:String = "ext"):Bool {
        return untyped __cpp__('R_SUCCEEDED(archiveCommitSaveData(partition.c_str()))');
    }

    /**
     * Variable for the concurrent Play Coins in your system found by `/gamecoin.dat`.
     * 
     * Note: If any of the FS API failed, `-1` will be returned!
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
    
    static function set_playCoins(playCoins:UInt16):UInt16 {
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
            
            playCoins = playCoins > 300 ? 300 : playCoins < 0 ? 0 : playCoins;
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
     * Exits FS.
     */
    @:native("fsExit")
    public static function exit() {}
}