# 1.3.0

CFGU:
- Added `systemUsername` and `systemBirthday`.
- Converted `systemModel`, `systemRegion` and `systemLanguage` to a string variable.

AC:
- `ssid`: Use `ACI_GetNetworkWirelessEssidSecuritySsid` instead of `ACU_GetSSID`

FS:
- Added `mountSaveData` and `flushAndCommit`

Compiler:
- Updated to be a little more smarter at fixing compilation errors (can only fix `error: cannot convert 'const std::nullopt_t' to` only.)
- *Intentionally* hidden the stdout thing for no reason.
- Switched to use STD C++23 instead of STD C++17, which also means `array.remove`, `array.indexOf`, etc. is fixed!!

# 1.2.0

- Added this release markdown so i don't forget what i've done.
- Added FRD service.
- **FULLY** Added the whole GSPLCD service.
- Added support for DYNAMIC variables.
- Updated almost every functions to be a variable property (which is easier).

# 1.0.0 - 1.1.0

Most likely initial release