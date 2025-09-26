package haxe3ds.services;

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
     */
    var dataSet:Bool;

    /**
     * Whetever or not the notification is unread by the News Applet.
     */
    var unread:Bool;

    /**
     * Whetever or not the image is a jpeg or not.
     */
    var enableJPEG:Bool;

    /**
     * Whetever or not the notification is a SpotPass or a StreetPass using CECD
     */
    var isSpotPass:Bool;

    /**
     * Whetever or not this notification was opted out.
     */
    var isOptedOut:Bool;

    /**
     * Notification source (zero for system notifications) 
     */
    var processID:UInt64;

    /**
     * Specified by source app and later retrieved via APT to identify which notification, if any, it was launched from 
     */
    var jumpParam:UInt64;

    /**
     * Milliseconds since January 1, 2000.
     */
    var time:UInt64;

    /**
     * UTF-16 to string converted for the notification title.
     */
    var title:String;
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
    public static function init() {
        untyped __cpp__('
            newsInit();

            Result r = 0;
            if (R_FAILED(r = NEWS_GetTotalNotifications(&totalNotifications))) {
                totalNotifications = r;
            }
        ');
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
    public static function addNotification(title:String, message:String, imagePath:String = "null"):Bool {
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

        final success:Bool = untyped __cpp__('R_SUCCEEDED(NEWS_AddNotification(OutTitle, title.size(), OutMessage, message.size(), image, size, true))');
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
        untyped __cpp__('
            NotificationHeader h;
            NEWS_GetNotificationHeader(newsID, &h)
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
            title:      untyped __cpp__('u16ToString(h.title, 64)')
        }
    }

    /**
     * Sets a header from the specified news ID and output. Todo: fix returning false everytime
     * @param newsID Identification of the current news.
     * @param out Header Type-Definition to use.
     * @return true if success, false if failed.
     * @since 1.3.0
     */
    public static function setHeader(newsID:Int, out:NEWSHeader):Bool {
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

        return untyped __cpp__('R_SUCCEEDED(NEWS_SetNotificationHeader(newsID, &h))');
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