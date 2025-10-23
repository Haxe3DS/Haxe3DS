package haxe3ds.services;

import haxe3ds.Types.Result;

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
}
    
static FS_Archive sdmcRoot;')
@:headerInclude("haxe3ds_services_GFX.h")
class FS {
    /**
     * Initializes FS.
     */
    public static function init() {
        untyped __cpp__('
            fsInit();
            FSUSER_IsSdmcDetected(&isSDMCDetected);
            FSUSER_IsSdmcWritable(&isSDMCWritable);

            FSUSER_OpenArchive(&sdmcRoot, ARCHIVE_SDMC, fsMakePath(PATH_EMPTY, ""))
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
     * @param partition Partition of the save data to use, Leave default for `ext`
     * @param files Files to actually store in the save data (will be calculated by `getHashTableLength`).
     * @param dirs Same as `files`.
     * @return Result code of whetever something from the services went wrong.
     * @since 1.3.0
     */
    public static function mountSaveData(partition:String = "ext", files:Int = 1, dirs:Int = 1):Result {
        var res:Result = 0;

        untyped __cpp__('
            bool retry = false;
            const char* p = partition.c_str();
            int i = getHashTableLength(dirs), j = getHashTableLength(files);

            FS_Path path = fsMakePath(PATH_EMPTY, "");
            res = archiveMount(ARCHIVE_SAVEDATA, path, p);
            if (res == 0xC8A04554) { // save format error
                res = FSUSER_FormatSaveData(ARCHIVE_SAVEDATA, path, 0x200, dirs, files, i, j, false);
                if (R_FAILED(res)) {
                    return res;
                }

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
     * @return Result code of whetever something from the services went wrong.
     * @since 1.3.0
     */
    public static function flushAndCommit(partition:String = "ext"):Result {
        return untyped __cpp__('archiveCommitSaveData(partition.c_str())');
    }

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
    
    static function set_playCoins(playCoins:UInt16):UInt16 {
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
     * @return Result of whetever the function succeded or not.
     * @since 1.4.0
     */
    public static function deleteFile(path:String):Result {
        return untyped __cpp__('FSUSER_DeleteFile(sdmcRoot, fsMakePath(PATH_ASCII, path.c_str()))');
    }

    /**
     * Renames a file in SDMC from `source` to `destination`.
     * 
     * Possible Result Code(s):
     * - `0xC82047EF` - File's source does not exist, destination already exist or it's source/destination had illegal characters.
     * 
     * @param source The source file to find and rename.
     * @param destination The new file name to use.
     * @return Result of whetever the function succeded or not.
     */
    public static function renameFile(source:String, destination:String):Result {
        return untyped __cpp__('FSUSER_RenameFile(sdmcRoot, fsMakePath(PATH_ASCII, source.c_str()), sdmcRoot, fsMakePath(PATH_ASCII, destination.c_str()))');
    }

    /**
     * Deletes a directory or even recursively deletes a directory!
     * @param source Source Directory to Use.
     * @param recursive Whetever or not should recursively delete the directory.
     * @return Result of whetever the function succeded or not.
     * @since 1.5.0
     */
    public static function deleteDir(source:String, recursive:Bool = false):Result {
        untyped __cpp__('FS_Path p = fsMakePath(PATH_ASCII, source.c_str())');
        return untyped __cpp__('recursive ? FSUSER_DeleteDirectoryRecursively(sdmcRoot, p) : FSUSER_DeleteDirectory(sdmcRoot, p)');
    }

    /**
     * Closes SDMC Archive and Exits FS.
     */
    public static function exit() {
        untyped __cpp__('
            FSUSER_CloseArchive(sdmcRoot);
            fsExit()
        ');
    }
}

/**
 * File Handler for reading/writing file.
 * 
 * @since 1.3.0
 */
@:headerClassCode('Handle h = 0;')
class FSFile {
    var path:String;

    /**
     * The error for whetever something went wrong for this service.
     * 
     * @since 1.4.0
     */
    public var result:Result = 0;

    /**
     * The current size get from for readed file.
     * 
     * This is also the offset of the amount of bytes.
     */
    public var byteSize:UInt32 = 0;

    /**
     * Creates a new file handler from `SDMC`.
     * @param path Path to open in.
     */
    public function new(path:String) {
        this.path = path;

        untyped __cpp__('
            this->result = FSUSER_OpenFile(&h, sdmcRoot, fsMakePath(PATH_ASCII, path.c_str()), FS_OPEN_CREATE | FS_OPEN_READ | FS_OPEN_WRITE, FS_ATTRIBUTE_ARCHIVE);
            if (R_SUCCEEDED(this->result)) {
                u64 by = 0;
                FSFILE_GetSize(h, &by);
                this->byteSize = (u32)by;
            }
        ');
    }

    /**
     * Writes the current file handle running, this will overwrite the result code from this class.
     * @param str String to write.
     * @param offset Offset of the string to use, if a number is negative then uses `this.byteSize`.
     */
    public function write(str:String, offset:UInt32 = -1) {
        if (offset < 0) {
            offset = byteSize;
        }

        untyped __cpp__('
            u32 bw = 0;
            result = FSFILE_Write(h, &bw, offset, str.c_str(), str.size(), FS_WRITE_FLUSH);
            byteSize += bw
        ');
    }

    /**
     * Reads a file from the handle, also updates the result code.
     * @param offset Offset to use
     * @param len Length to read, if `-1` then uses `this.byteSize`.
     * @return String read from file.
     */
    public function read(offset:UInt32 = 0, len:UInt32 = -1):String {
        if (len == -1) {
            len = byteSize;
        }
        len = Std.int(Math.abs(len));

        var out:String = "";
        untyped __cpp__('
            u32 r = 0;
            const char* shit = "";
            result = FSFILE_Read(h, &r, offset, (char*)(shit), len);
            out = std::string((char*)(shit))
        ');
        return out;
    }

    /**
     * Resize the file to whatever you want, also resizes `this.byteSize`! It will also update the result code.
     * @param amount The amount to resize.
     * @since 1.4.0
     */
    public function resize(amount:UInt64) {
        byteSize = amount;
        result = untyped __cpp__('FSFILE_SetSize(h, amount)');
    }

    /**
     * Closes a file and closes the archive (saves memory?).
     * 
     * Also updates the result code.
     */
    public function close() {
        result = untyped __cpp__('FSFILE_Close(h)');
    }
}