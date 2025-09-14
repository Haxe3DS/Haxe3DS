# 1.3.0

CFGU:
- Added `systemUsername` and `systemBirthday`.
- Converted `systemModel`, `systemRegion` and `systemLanguage` to a string variable.

AC:
- `ssid`: Use `ACI_GetNetworkWirelessEssidSecuritySsid` instead of `ACU_GetSSID`

Compiler:
- Updated to be a little more smarter for fixing compilation (can only fix `error: cannot convert 'const std::nullopt_t' to` only.)

# 1.2.0

- Added this release markdown so i don't forget what i've done.
- Added FRD service.
- **FULLY** Added the whole GSPLCD service.
- Added support for DYNAMIC variables.
- Updated almost every functions to be a variable property (which is easier).

# 1.0.0 - 1.1.0

Most likely initial release