extends Node

const AppSettingsClass := preload("res://addons/kenyoni/app_settings/app_settings.gd")
const Setting := preload("res://addons/kenyoni/app_settings/setting.gd")

## only emitted once per frame
signal settings_applied()
## only emitted once per frame
signal settings_changed()
## only emitted once per frame
signal settings_staged_changed()

## Emitted when any setting has been applied.
## `key` is the StringName of the applied setting.
signal applied(key: StringName)
## Emitted when any setting's effective value has changed.
## `key` is the StringName of the changed setting.
signal changed(key: StringName)
## Emitted when any staged value has changed or been cleared.
## `key` is the StringName of the setting whose staged value changed.
signal staged_changed(key: StringName)

var _settings: AppSettingsClass = AppSettingsClass.new()

var _settings_applied: bool = false
var _settings_changed: bool = false
var _settings_staged_changed: bool = false

func _ready() -> void:
    self._settings.applied.connect(self._on_applied)
    self._settings.changed.connect(self._on_changed)
    self._settings.staged_changed.connect(self._on_staged_changed)

func _process(_delta: float) -> void:
    if self._settings_applied:
        self._settings_applied = false
        self.settings_applied.emit()
    if self._settings_changed:
        self._settings_changed = false
        self.settings_changed.emit()
    if self._settings_staged_changed:
        self._settings_staged_changed = false
        self.settings_staged_changed.emit()

## Add a new setting to the manager.
## Throw an error if the key is invalid or already exists.
func add(setting: Setting) -> void:
    self._settings.add(setting)

## Return true if a setting with the given key exists.
func has_setting(key: StringName) -> bool:
    return self._settings.has_setting(key)

## Return the setting for the given key, or null if it does not exist.
func get_setting(key: StringName) -> Setting:
    return self._settings.get_setting(key)


func remove(key: StringName) -> void:
    self._settings.remove(key)

## Return all settings within a section.
## - `section` is a key prefix.
## - `depth` controls how deep in the hierarchy to include settings (-1 for all).
## - `filter` Callable[[Setting], bool] can be used to include only specific settings.
func get_section(section: String, depth: int = -1, filter: Callable = AppSettingsClass._exclude_internal) -> Array[Setting]:
    return self._settings.get_section(section, depth, filter)

## Return the names of subsections within a section.
## - `parent_section` is the key prefix of the parent section.
## - `filter` Callable[[Setting], bool] can be used to include only specific settings.
func get_section_names(parent_section: String = "", filter: Callable = AppSettingsClass._exclude_internal) -> PackedStringArray:
    return self._settings.get_section_names(parent_section, filter)

## Apply all settings immediately.
func apply_all() -> void:
    self._settings.apply_all()

## Apply only staged values.
func apply_staged_values() -> void:
    self._settings.apply_staged_values()

## Clear all staged values.
func clear_staged_values() -> void:
    self._settings.clear_staged_values()

## Return true if any settings have staged values.
func has_staged_values() -> bool:
    return self._settings.has_staged_values()

## Convert exported settings to a ConfigFile.
## - `filter` Callable[[Setting], bool] can be used to include only specific settings.
func to_config(filter: Callable = Callable()) -> ConfigFile:
    return self._settings.to_config(filter)

## Load settings from a ConfigFile.
func load_config(config: ConfigFile) -> void:
    self._settings.load_config(config)

func _on_applied(key: StringName) -> void:
    self._settings_applied = true
    self.applied.emit(key)

func _on_changed(key: StringName) -> void:
    self._settings_changed = true
    self.changed.emit(key)

func _on_staged_changed(key: StringName) -> void:
    self._settings_staged_changed = true
    self.staged_changed.emit(key)
