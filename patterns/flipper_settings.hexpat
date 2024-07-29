/*!
    This pattern can be used to parse Flipper Zero settings.
    It supports SavedStructure based settings and Notification settings.
*/

#pragma author Jan Wiesemann
#pragma description Flipper Zero Settings

/**
    Infrared
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/applications/main/infrared/infrared_app.c#L17
*/
#define MAGIC_IR 0x1F
#pragma magic [ 1F ] @ 0x00

/**
    Expansion/UART
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/applications/services/expansion/expansion_settings.c#L10
*/
#define MAGIC_UART 0xEA
#pragma magic [ EA ] @ 0x00

/**
    Bluetooth
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/applications/services/bt/bt_settings.c#L9
*/
#define MAGIC_BT 0x19
#pragma magic [ 19 ] @ 0x00

/**
    Dolphin
    @source https://github.com/DarkFlippers/unleashed-firmware/blob/b2305ce5c7a6ab36babc30243a589eccfa9edcb6/applications/services/dolphin/helpers/dolphin_state.c#L14
*/
#define MAGIC_DOLPHIN  0xD0
#pragma magic [ 0D ] @ 0x00

/**
    Desktop
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/applications/services/desktop/desktop_settings.h#L14
*/
#define MAGIC_DEKTOP 0x17
#pragma magic [ 1/ ] @ 0x00

/* ======= Common structures =======

    Flipper datatype aliases
    They are added for easyer translatiom from the Flipper soruce into ImHex
*/
using int8_t = u8;
using uint8_t = u8;

using int16_t = u16;
using uint16_t = u16;

using int32_t = s32;
using uint32_t = u32;

using int64_t = s64;
using uint64_t = u64;

/* ======= Common structures ======= */

/**
    Header for a saved structure file
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/lib/toolbox/saved_struct.c#L14
*/
struct SavedStructHeader {
    uint8_t magic;
    uint8_t version;
    uint8_t checksum; //Sum of data-bytes
    uint8_t flags; //Not used always 0
    uint32_t timestamp; //Not used alwas 0
};

/* ======= Infrared settings '.infrared.settings' ======= */

/*
    Lists all avalible outputs for the Infrared appication
   @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/targets/furi_hal_include/furi_hal_infrared.h#L23
*/
enum FuriHalInfraredTxPin : uint8_t {
    FuriHalInfraredTxPinInternal,
    FuriHalInfraredTxPinExtPA7,
    FuriHalInfraredTxPinMax
};

/*
    Infrared Settings
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/applications/main/infrared/infrared_app.c#L22
*/
struct InfraredSettings {
    FuriHalInfraredTxPin tx_pin;
    bool otg_enabled;
};

/* ======= Expansion settings '.expansion.settings' ======= */

/**
    ???
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/applications/services/expansion/expansion_settings.h#L23
*/
struct ExpansionSettings {
    uint8_t uart_index;
};

/* ======= Bluetooth settings '.bt.settings' ======= */

/**
    Bluetooth Settings
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/applications/services/bt/bt_settings.h#L14
*/
struct BtSettings {
    bool enabled;
};

/* ======= Dolphin state '.dolphin.state' ======= */

/**
    Lists all avalible Apps, that grand you points
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/applications/services/dolphin/helpers/dolphin_deed.h#L18
*/
enum  DolphinApp : uint16_t {
    DolphinAppSubGhz,
    DolphinAppRfid,
    DolphinAppNfc,
    DolphinAppIr,
    DolphinAppIbutton,
    DolphinAppBadusb,
    DolphinAppPlugin,
    DolphinAppMAX
};

/**
    States for the Dolphin
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/applications/services/dolphin/helpers/dolphin_state.h#L17
*/
struct DolphinStoreData{
    uint8_t icounter_daily_limit[DolphinApp::DolphinAppMAX];
    uint8_t butthurt_daily_limit;
    uint32_t flags; // Not used always 0
    uint32_t icounter;
    int32_t butthurt;
    uint64_t timestamp;
    padding[4];
};

/* ======= Desktop settings '.dektop.settings' ======= */

#define MAX_PIN_SIZE   10
#define MIN_PIN_SIZE   4
#define MAX_APP_LENGTH 128

/**
    Represents a Input Key
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/targets/f7/furi_hal/furi_hal_resources.h#L22
*/
enum InputKey : uint8_t{
    InputKeyUp,
    InputKeyDown,
    InputKeyRight,
    InputKeyLeft,
    InputKeyOk,
    InputKeyBack,
    InputKeyMAX, /**< Special value */
};

/**
    Stores the Pin-Code
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/applications/services/desktop/desktop_settings.h#L58
*/
struct PinCode{
    InputKey data[MAX_PIN_SIZE];
    uint8_t length;
};

/**
    Possible buttons for the Shortcut menu
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/applications/services/desktop/desktop_settings.h#L45
*/
enum FavoriteAppShortcut : uint32_t {
    FavoriteAppLeftShort,
    FavoriteAppLeftLong,
    FavoriteAppRightShort,
    FavoriteAppRightLong,
    FavoriteAppNumber
};
/**
    Possible buttons for the Shortcut menu while using the dummy mode
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/applications/services/desktop/desktop_settings.h#L53
*/
enum DummyAppShortcut : uint32_t{
    DummyAppLeft = 0,
    DummyAppRight,
    DummyAppDown,
    DummyAppOk,
    DummyAppNumber,
};

/**
    Path or Appname for a Shortcut
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/applications/services/desktop/desktop_settings.h#L62
*/
struct FavoriteApp {
    char name_or_path[MAX_APP_LENGTH];
};
/**
    Settings for the Desktop
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/applications/services/desktop/desktop_settings.h#L71
*/
struct DesktopSettings {
    PinCode pin_code;
    padding[1];
    uint32_t auto_lock_delay_ms;
    uint8_t dummy_mode;
    uint8_t display_clock;
    FavoriteApp favorite_apps[FavoriteAppShortcut::FavoriteAppNumber];
    FavoriteApp dummy_apps[DummyAppShortcut::DummyAppNumber];
    padding[2];
};

/* ======= Helper======= */

/**
    Container for SavedStruct based settings
*/
struct SavedStructure {
    SavedStructHeader header;

    match(header.magic, sizeof($) - sizeof(SavedStructHeader)) {
        (MAGIC_IR, sizeof(InfraredSettings)): InfraredSettings infraredSettings;
        (MAGIC_UART, sizeof(ExpansionSettings)): ExpansionSettings expansionSettings;
        (MAGIC_BT, sizeof(BtSettings)): BtSettings btSettings;
        (MAGIC_DOLPHIN, sizeof(DolphinStoreData)): DolphinStoreData dolphinStoreData;
        (MAGIC_DEKTOP, sizeof(DesktopSettings)): DesktopSettings desktopSettings;
    }
};

/**
    Settings for the LCD and Notifications
    @source https://github.com/flipperdevices/flipperzero-firmware/blob/a403e5f543a5423e39ac1700ae4711e9e489445e/applications/services/notification/notification_app.h#L46
*/
struct NotificationSettings {
    uint8_t version;
    padding[3];
    float display_brightness;
    float led_brightness;
    float speaker_volume;
    uint32_t display_off_delay_ms;
    int8_t contrast;
    bool vibro_on;
    padding[2];
};

/**
    Wrapper for SavedStructure or Notificaition settings
*/
struct FlipperSettings {
    if(sizeof($) == sizeof(NotificationSettings))
        NotificationSettings notificationSettings;
    else
        SavedStructure savedStructure;
};
FlipperSettings flipperSettings @ 0x00;
