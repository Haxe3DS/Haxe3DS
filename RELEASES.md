# 1.9.1

Fixed bug where it throws error about romfs path variable not found, this is what happens if i don't test it after release

# 1.9.0

MODULE       | CHANGES
-------------|---------
!            | Most functions are inlined.
AC           | Added enum `ACWifiStatus`.
APT          | Grammar fix. `Happend` => `Happened`.
CFG          | Added enum `CFGSoundOutput`, Fix `username` by using the correct alignment, added `set_soundOutput` with bounds checking.
Console      | Renamed a lot of variables, added `WIDTH`, `HEIGHT`, `WIDTH_BOTTOM`.
Error Applet | Optimized for less lines.
FRD          | Re-added `preference`, with getter and setter supported.
FS           | Removed `FSFile`, Wrapped `mountSaveData` and `flushAndCommit` by `#if IS_CIA`
GFX          | Made `current3D` and `isWide` a static variable, somehow it wasn't static so it wouldn't show.
MCU          | Fix Compiler error from `temperature` involving not converting a Dynamic to UInt8
News         | Replaced FS API to use STDIO API for FILE from `dumpImage`.
Voice Sel    | Optimized for less lines.
Haxe3DS      | Possible fix for when Trying to compile and that any of the resource directory isn't found.
Tool         | Add defines to correspond if it uses 3DSX `IS_3DSX` or CIA `IS_CIA`.
Types        | Moved all classes to the `types` directory.

# 1.8.1

Fixed a crash on News.addNotification about `_free_r_`

# 1.8.0

MODULE       | CHANGES
-------------|---------
Some of Them | Optimized function calls for less usage and more speed.
Builder      | Now migrated to Haxe for handling everything instead of Python
BuildInfo    | Added Variable `DATE`, Fixed a bug where starting files/dirs is "." would just skip.
Event        | Changed to handle adding more Arguments.
FRD          | Added new Argument for `init` called `enableNotifications`, Optimized by adding a function for parsing FRDDetail, Added for Threads.
GFX          | Renamed `initDefault` to `init`.
HID          | Added function `waitForKeyPress(UInt32, Bool)`, renamed `Key` to `HIDKey` to not be confused with `sys.ssl.Key`
News         | Added `OutOfBoundsException`, `NewsLampPattern` and `flashLEDPattern(NewsLampPattern)` with bounds checking, Reworked on `addNotification`
PLGLDR       | Added Class.
SVC          | Added `SVCEmulatorID`, `SVCEmulatorPlatform`, `SVCEmulatorInfo` and `emulator`

The most effort i've worked on is News, I really like News. - nael2xd

# 1.7.0

MODULE     | CHANGES
-----------|---------
!          | Migrated from reflaxe.CPP to HXCPP, this support even more libraries but beware of memory leaks, This also increases the size of the Output by a lot!
BuildInfo  | Added Class, for Build Information.
CFG        | Renamed `CFGU` to `CFG`, 
Everything | Fixed a bunch of Errors from that Migration, and Replace a bunch of enum to enum abstract.
GFX        | Replaced `haxe.Log.trace` with custom one (This also prints using SVC.debugString)
PTM        | Renamed PTMU/PTMSYSM to PTM.
RomFS      | Changed Documentation.
SVC        | Added Class.
Types      | Added 2 types: `NanoTime` and `Event<Args>`
Utils      | Added .h file to handle a bunch of things.

There is so many that i don't even know if I missed one or not.

# 1.6.0

Note: 1.7.0 will migrate to using HXCPP instead of reflaxe.CPP.

MODULE        | CHANGES
--------------|---------
AM            | Added class.
APT           | Added enum: `APTSystemSettingsFlag`, `APTHookType`, variable: `hookHandler`, and function: `jumpToSystemSettingsWithFlag(APTSystemSettingsFlag)`
Builder       | Fixed a bug that i didn't notice???
CFGU          | Added typedef: `CFGUBacklightControl`, function: `getBacklightControl()`, and general fixes.
FS            | Added `ctrRootPath`, and enum: `FSMediaType`, and an almost complete list of SMDH.
HID           | Switch to using vars instead of functions for gyroscope, touch position, etc.
MCU           | Renamed CLASS and added `temperature`.
NEWS          | Added `browser` to `NEWSHeader`
reflaxe.CPP   | Added support string for typedef.

# 1.5.0

MODULE        | CHANGES
--------------|---------
ACT           | Added `isConnected(Bool)`
APT           | Added `cpuTimeLimit`
Compiler      | Used multi threading to decrease compile time by 3x and ~~Heavily lowered build size by 4x.~~
CFGU          | Added enum: `CFGURestrictBitmask`, typedef: `CFGUParental` and `CFGUUsername`, function: `getParentalControlInfo`, variable: `soundOutput`, and renamed a lot of variables.
Env           | Added `isUsing3DS`
Error         | Rewording and moved typedef variables to Class instead.
FRD           | Added `FRDNotifTypes`, `notifCallback:(FRDFriendDetail, FRDNotifTypes)->Void`, Optimized by removing vars to place in `FRDFriendDetail`.
FS            | Added `deleteDir(String)`, added function being FSFILE.writeVoid(VoidPtr, Int, Int) and renamed FSFILE.write() to FSFILE.writeString();
HTTPC         | Added Class.
OS            | Added `getKernelConfig()`, and added struct: `OSConfig`, and enums too: `OSBootEnv`, `OSRunningHW`, `OSNetwork`.
SWKBD         | Rewording because it didn't make sense or just removed useless pieces of data.
WebBrowser    | Added Class.
VoiceSelector | Added Class.

# 1.4.0

MODULE      | CHANGES
------------|---------
ACT         | Added Class.
APT         | Added variable: `programID`.
Compiler    | Implemented a bug fix.
FRD         | Added functions: `updateComment(String)`, `halfAwake(Bool)`, `FRDRelationship`, and Fixed connection stuff.
FS          | Added `deleteFile(String)`, `renameFile(String, String)`
FSUtil      | Optimized and Increase the speed of reading files. (?)
FSFile      | Added `resize()` and `result`, added argument on `write`, fixed constructor?
MCUWUC      | Added Class.
News        | Added `dumpImage(UInt32, String)`, reworded some vars/functions.
NS          | Added `terminate()`.
OS          | Added `version`, `versionToInt(String)`.
Reflaxe.CPP | Fixed `Anon.hx` dynamic behavior that causes too much compiler errors.
REPO        | New Logo thanks to @h3ath3rr!.
SWKBD       | Added `callbackFN`, `SWKBDCallbackTypes`, `SWKBDCallbackReturn`.
Types       | Added `Result` which is used for better debugging.

# 1.3.0

AC:
- `ssid`: Use `ACI_GetNetworkWirelessEssidSecuritySsid` instead of `ACU_GetSSID`

CFGU:
- Added `systemUsername` and `systemBirthday`.
- Converted `systemModel`, `systemRegion` and `systemLanguage` to a string variable.

Compiler:
- Updated to be a little more smarter at fixing compilation errors.
- *Intentionally* hidden the stdout/stderr output for no reason.
- Switched to use STD C++23 instead of STD C++17, which also means `array.remove`, `array.indexOf`, etc. is fixed!!
- Moved 3DS IP related to a key:value and also added `debugMode`!
- Fixed bugs where it would overwrite the devkitPro's libctru header file which was dangerous.
- Handled linker errors by breaking them.
- No longer use `Makefile` in local assets, now it will be in haxelib assets.

ENV:
- Initial New Class.

Error:
- Class has been fully documented and fully done!

FRD:
- Fixed a bug where it had 2 `showGameName` in both `FRD_GetMyPreference` and `FRDA_UpdatePreference` arguments causing inaccuracies.

FS:
- Added `mountSaveData`, `flushAndCommit` and `playCoins`
- Added Class being `FSFile`!
- Added additional error handling.

GSPLCD:
- Remove `get_LED`

News:
- Class has been fully documented and fully done(?)

STDs:
- Initial New Classes (StringUtil, CTime).

Other:
- Moved Installation into Wiki!
- VSCode: Fixed typedefs not showing details about info from variables.
- Moved other haxe files to separate folders for cleaning.
- New Logo!

# 1.2.0

- Added this release markdown so i don't forget what i've done.
- Added FRD service.
- **FULLY** Added the whole GSPLCD service.
- Added support for DYNAMIC variables.
- Updated almost every functions to be a variable property (which is easier).

# 1.0.0 - 1.1.0

Most likely initial release
