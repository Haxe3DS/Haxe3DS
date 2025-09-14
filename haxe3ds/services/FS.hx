package haxe3ds.services;

enum MediaType {
    NAND;
    SD;
    GAME_CARD;
}

/**
 * File System Service.
 * 
 * ### !! WIP !!
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
     */
    public static function flushAndCommit(partition:String = "ext"):Bool {
        return untyped __cpp__('R_SUCCEEDED(archiveCommitSaveData(partition.c_str()))');
    }

    /**
     * Exits FS.
     */
    @:native("fsExit")
    public static function exit() {}
}