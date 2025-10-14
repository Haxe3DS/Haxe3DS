# 1.5.0

MODULE      | CHANGES
------------|---------
Compiler    | Used multi threading to decrease compile time by 3x.
Compiler    | Heavily lowered build size by 4x.
FS          | Added `deleteDir(String)`.

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