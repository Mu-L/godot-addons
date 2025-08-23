extends Node

const Setting := preload("res://addons/kenyoni/app_settings/setting.gd")

enum GameDifficulty {
    EASY,
    NORMAL,
    HARD
}

enum GraphicDetails {
    LOW,
    MEDIUM,
    HIGH,
    ULTRA
}

const GAME_DIFFICULTY: StringName = &"game/difficulty"
const GAME_PLUGINS: StringName = &"game/plugins"
const GAME_BOT_LEVEL: StringName = &"game/bot_level"
const GAME_LANGUAGE: StringName = &"game/language"
const GAME_ADVANCED_KI: StringName = &"game/advanced_ki"
const GRAPHICS_DETAILS: StringName = &"graphics/common/details"
const GRAPHICS_DISPLAY_WINDOW_MODE: StringName = &"graphics/display/window_mode"
const GRAPHICS_DISPLAY_VSYNC: StringName = &"graphics/display/vsync"

## For localization use TranslationServer.get_loaded_locales() to get available languages.
## use "display_values" to set the display names for a list of values or enums.
## Almost always use .add_meta("type", TYPE_XXX). You could also just check for set.value() is bool, etc. But if the value allows null or it is an enum, it is better to define the type this way.
static func _static_init() -> void:
    print("Initializing game settings...")
    AppSettings.add(Setting.new(GAME_DIFFICULTY, GameDifficulty.NORMAL)
    .set_description("The difficulty of the game.")
    .set_staged()
    .add_meta("type", TYPE_INT)
    .add_meta("hint", PROPERTY_HINT_ENUM)
    .add_meta("values", GameDifficulty.keys())
    .add_meta("display_values", ["difficulty_easy", "difficulty_normal", "difficulty_hard"])
    .set_validate_fn(func(_stg: Setting, val: Variant): return val in GameDifficulty.keys()))
    AppSettings.add(Setting.new(GAME_ADVANCED_KI, false)
    .set_description("Enable advanced AI features (experimental).")
    .set_advanced()
    .set_staged()
    .add_meta("type", TYPE_BOOL)
    .add_meta("values", GameDifficulty.keys()))
    AppSettings.add(Setting.new(GAME_LANGUAGE, TranslationServer.get_locale())
    .set_description("The language of the game.")
    .set_staged()
    .add_meta("type", TYPE_STRING)
    .add_meta("hint", PROPERTY_HINT_ENUM)
    .add_meta("values", ["en", "de"])
    .add_meta("display_values", ["lang_en", "lang_de"])
    .set_validate_fn(func(_stg: Setting, val: Variant): return val in TranslationServer.get_loaded_locales())
    .set_apply_fn(func(stg: Setting) -> void: TranslationServer.set_locale(stg.value() as String)))
    AppSettings.add(Setting.new(GRAPHICS_DETAILS, GraphicDetails.MEDIUM)
    .set_description("Graphic detail level.")
    .set_staged()
    .add_meta("type", TYPE_INT)
    .add_meta("hint", PROPERTY_HINT_ENUM)
    .add_meta("values", GraphicDetails.keys())
    .add_meta("display_values", ["details_low", "details_medium", "details_high", "details_ultra"])
    .set_validate_fn(func(_stg: Setting, val: Variant): return val in GraphicDetails.keys()))
    AppSettings.add(Setting.new(GRAPHICS_DISPLAY_WINDOW_MODE, false)
    .set_description("Enable fullscreen mode.")
    .set_staged()
    .add_meta("type", TYPE_INT)
    .add_meta("hint", PROPERTY_HINT_ENUM)
    .add_meta("values", [DisplayServer.WINDOW_MODE_WINDOWED, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN, DisplayServer.WINDOW_MODE_FULLSCREEN])
    .add_meta("display_values", ["window_mode_windowed", "window_mode_exclusive_fullscreen", "window_mode_fullscreen"])
    .set_apply_fn(func(stg: Setting) -> void:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if stg.value() else DisplayServer.WINDOW_MODE_WINDOWED)))
    AppSettings.add(Setting.new(GRAPHICS_DISPLAY_VSYNC, false)
    .set_description("VSync.")
    .set_advanced()
    .set_staged()
    .add_meta("type", TYPE_BOOL))
    AppSettings.add(Setting.new(GAME_PLUGINS, [])
    .set_description("Enabled plugins.")
    .set_internal()
    .add_meta("type", TYPE_ARRAY)
    .add_meta("hint", PROPERTY_HINT_TYPE_STRING))
    AppSettings.add(Setting.new(GAME_BOT_LEVEL, 10)
    .set_description("Bot level.")
    .set_internal()
    .set_no_export()
    .add_meta("type", TYPE_INT))
    AppSettings.apply_all()
