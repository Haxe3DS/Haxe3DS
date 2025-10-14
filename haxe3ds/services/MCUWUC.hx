package haxe3ds.services;

/**
 * mcuHwc service.
 * 
 * @since 1.4.0
 */
@:cppInclude("haxe3ds_services_GFX.h")
class MCUWUC {
    /**
     * Initializes MCUHWC for other variables to work.
     */
    public static function init() {
        untyped __cpp__('
            mcuHwcInit();

            u8 a, b;
            MCUHWC_GetFwVerHigh(&a);
            MCUHWC_GetFwVerLow(&b);

            char out[8];
            std::snprintf(out, 8, "%u-%u", a, b);
            mcuVersion = out;
        ');
    }

    /**
     * Exits MCUHWC.
     */
    @:native("mcuHwcExit")
    public static function exit() {}

    /**
     * @see https://www.3dbrew.org/wiki/MCUHWC:GetBatteryVoltage
     */
    public static var batteryVoltage(get, null):UInt8 = 0;
    static function get_batteryVoltage():UInt8 {
        var out:UInt8 = 0;
        untyped __cpp__('MCUHWC_GetBatteryVoltage(&out)');
        return out;
    }

    /**
     * The current percentage on your 3DS `0 - 100 (0x64)`
     */
    public static var batteryPercentage(get, null):UInt8;
    static function get_batteryPercentage():UInt8 {
        var out:UInt8 = 0;
        untyped __cpp__('MCUHWC_GetBatteryLevel(&out)');
        return out;
    }

    /**
     * Variable if you wanna set the wifi led state to on or off.
     */
    public static var wifiLEDState(null, set):Bool;
    static function set_wifiLEDState(wifiLEDState:Bool):Bool {
        untyped __cpp__('MCUHWC_SetWifiLedState(wifiLEDState)');
        return wifiLEDState;
    }

    /**
     * The current MCU Firmware Version by this format: `%u-%u`.
     * 
     * Note:
     * - It starts with `HI-LO`.
     */
    public static var mcuVersion(default, null):String = "";
}