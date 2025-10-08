package haxe3ds.services;

import haxe3ds.Types.Result;
import haxe3ds.stdutil.FSUtil;

using StringTools;

/**
 * The Notification Header.
 * 
 * @since 1.3.0
 */
typedef NEWSHeader = {
    /**
     * Whetever or not the data's fully set or not.
     * 
     * Useless?
     */
    var dataSet:Bool;

    /**
     * Whetever or not the notification is unread by the News Applet.
     * 
     * If it's still unread, it would show a `blue` or `green` circle light.
     */
    var unread:Bool;

    /**
     * Whetever or not the image is a JPEG or not.
     */
    var enableJPEG:Bool;

    /**
     * Whetever or not the notification is a SpotPass or a StreetPass using CECD.
     * 
     * Note: If set to `true`, shows a "Opt out of notifications for this software" in the Notification Applet.
     */
    var isSpotPass:Bool;

    /**
     * Whetever or not this notification was opted out.
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
     * The result code called from `News.getHeader`.
     * 
     * This is not used anywhere.
     */
    var result:Result;
}

/**
 * News (Notification Appleter) Service.
 * 
 * Currently a total train wreck caused by LibCTRU devs, so this is broken atm, unless you know how to fix this (which is just replacing `news:u` to `news:s`), this will never work.
 */
@:cppFileCode('
#include <string.h>
#include "haxe3ds_Utils.h"
')
class News {
    /**
     * Initializes NEWS.
     */
    public static function init():Result {
        var ret:Result = 0;

        untyped __cpp__('
            ret = newsInit();

            Result r = 0;
            if (R_FAILED(r = NEWS_GetTotalNotifications(&totalNotifications))) {
                totalNotifications = r;
            }
        ');

        return ret;
    };

    /**
     * Exits NEWS.
     */
    @:native("newsExit")
    public static function exit() {};

    /**
     * Adds a notification to the home menu Notifications applet. TODO: fix images.
     * @param title String title of the notification, maximum `0x40` or `64` characters.
     * @param message String message of the notification, or `""` for no message. maximum `0x1780` or `6016` characters.
     * @param imagePath Path to the image, make sure the image is less than 0xC800 (or 65536) bytes! **NOTE**: only supports sdmc.
     * @return true if success, false if failed.
     * @since 1.3.0
     */
    public static function addNotification(title:String, message:String, imagePath:String = "null"):Result {
        untyped __cpp__("
            u16 OutTitle[0x40] = {0};
            u16 OutMessage[0x1780] = {0}; // cause why not lool

            const char* t = title.c_str();
            const char* m = message.c_str();

            for (size_t i = 0; i < title.size(); i++) OutTitle[i] = t[i];
            for (size_t i = 0; i < message.size(); i++) OutMessage[i] = m[i];

            u64 size = 0;
            u8* image = NULL;
        ");

        if (imagePath != "null" && FSUtil.exists(imagePath) && (imagePath.endsWith("jpg") || imagePath.endsWith("jpeg"))) {
            imagePath.startsWith("/") ? null : imagePath = '/$imagePath';

            untyped __cpp__('
                Handle h;
                
                FS_Archive arch = 0;
                if (R_FAILED(FSUSER_OpenArchive(&arch, ARCHIVE_SDMC, fsMakePath(PATH_EMPTY, "")))) {
                    goto fail1;
                }

                if (R_FAILED(FSUSER_OpenFile(&h, arch, fsMakePath(PATH_ASCII, imagePath.c_str()), FS_OPEN_READ, FS_ATTRIBUTE_READ_ONLY))) {
                    goto fail2;
                }
                    
                image = (u8*)malloc(0xC800);
                FSFILE_GetSize(h, &size);
                if (size < 0xC800) {
                    u32 u;
					FSFILE_Read(h, &u, 0, &image, size);
                    FSFILE_Close(h);
                }

                svcCloseHandle(h);
                fail2:
                FSUSER_CloseArchive(arch);
                fail1:
            ');
        }

        final success:Result = untyped __cpp__('NEWS_AddNotification(OutTitle, title.size(), OutMessage, message.size(), image, size, true)');
        untyped __cpp__('if (image != NULL) free(image)');

        return success;
    }

    /**
     * Gets the ID Header for the news.
     * @param newsID ID to use.
     * @return Type-Definition for this ID.
     * @since 1.3.0
     */
    public static function getHeader(newsID:Int):NEWSHeader {
        var ret:Result = 0;

        untyped __cpp__('
            NotificationHeader h;
            ret = NEWS_GetNotificationHeader(newsID, &h)
        ');

        return {
            dataSet:    untyped __cpp__('h.dataSet'),
            unread:     untyped __cpp__('h.unread'),
            enableJPEG: untyped __cpp__('h.enableJPEG'),
            isSpotPass: untyped __cpp__('h.isSpotPass'),
            isOptedOut: untyped __cpp__('h.isOptedOut'),
            processID:  untyped __cpp__('h.processID'),
            jumpParam:  untyped __cpp__('h.jumpParam'),
            time:       untyped __cpp__('h.time'),
            title:      untyped __cpp__('u16ToString(h.title, 64)'),
            result:     ret
        }
    }

    /**
     * Sets a header from the specified news ID and output. Todo: fix returning false everytime
     * @param newsID Identification of the current news.
     * @param out Header Type-Definition to use.
     * @return Result code to check if something went wrong.
     * @since 1.3.0
     */
    public static function setHeader(newsID:Int, out:NEWSHeader):Result {
        untyped __cpp__('
            NotificationHeader h;
            NEWS_GetNotificationHeader(newsID, &h);

            h.dataSet = out->dataSet;
            h.unread = out->unread;
            h.enableJPEG = out->enableJPEG;
            h.isSpotPass = out->isSpotPass;
            h.isOptedOut = out->isOptedOut;
            h.processID = out->processID;
            h.jumpParam = out->jumpParam;
            h.time = out->time;
            utf8_to_utf16(h.title, (const u8*)out->title.c_str(), out->title.size());
        ');

        return untyped __cpp__('NEWS_SetNotificationHeader(newsID, &h)');
    }

    /**
     * Dumps the MPO image to `SDMC` from the specified news.
     * 
     * Possible Result Code(s):
     * - `0xC8804470` - News MPO image was not found and cannot be dumped.
     * - `0xD8E007F7` - Invalid handle, it's either `News` or `FS` that was not initialized.
     * 
     * @param newsID News Identification to Use.
     * @param dumpDest Dump Path Destination to Use.
     * @return Result code to check if something went wrong.
     */
    public static function dumpImage(newsID:UInt32, dumpDest:String):Result {
        var ret:Result = 0;

        untyped __cpp__('
            u32 total;
            FS_Archive arch;
            Handle h;
            u32 size;
            void* data = malloc(0x10000);
            u32 bw;

            ret = NEWS_GetNotificationImage(newsID, data, &size);
            if (R_FAILED(ret)) {
                goto fail1;
            }

            ret = FSUSER_OpenArchive(&arch, ARCHIVE_SDMC, fsMakePath(PATH_EMPTY, ""));
            if (R_FAILED(ret)) {
                goto fail1;
            }

            ret = FSUSER_OpenFile(&h, arch, fsMakePath(PATH_ASCII, dumpDest.c_str()), FS_OPEN_CREATE | FS_OPEN_READ | FS_OPEN_WRITE, FS_ATTRIBUTE_ARCHIVE);
            if (R_FAILED(ret)) {
                goto fail2;
            }

            ret = FSFILE_Write(h, &bw, 0, data, size, FS_WRITE_FLUSH);

            FSFILE_Close(h);
            fail2:
            FSUSER_CloseArchive(arch);
            fail1:
            free(data);
        ');

        return ret;
    }

    /**
     * Variable property that gets current total notifications number.
     * 
     * Error Codes:
     * - `0xD900182F (3640662063)` - Due to LibCTRU's amazing coding skills, they've used `news:u` instead of `news:s` and thus is the reason why it caused this amazing error.
     * 
     * @see https://github.com/devkitPro/libctru/issues/587 `(0xD900182F)`
     */
    public static var totalNotifications(default, null):UInt32;
}