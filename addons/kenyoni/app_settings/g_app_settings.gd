extends Node

const AppSettingsClass := preload("res://addons/kenyoni/app_settings/app_settings.gd")
const Setting := preload("res://addons/kenyoni/app_settings/setting.gd")

## only emitted once per frame
signal settings_applied()
## only emitted once per frame
signal settings_changed()
## only emitted once per frame
signal settings_pending_changed()

signal applied(key: StringName)
signal changed(key: StringName)
signal pending_changed(key: StringName)

var _settings: AppSettingsClass = AppSettingsClass.new()

var _settings_applied: bool = false
var _settings_changed: bool = false
var _settings_pending_changed: bool = false

func _ready() -> void:
    self._settings.applied.connect(self._on_applied)
    self._settings.changed.connect(self._on_changed)
    self._settings.pending_changed.connect(self._on_pending_changed)

func _process(_delta: float) -> void:
    if self._settings_applied:
        self._settings_applied = false
        self.settings_applied.emit()
    if self._settings_changed:
        self._settings_changed = false
        self.settings_changed.emit()
    if self._settings_pending_changed:
        self._settings_pending_changed = false
        self.settings_pending_changed.emit()

func add(setting: Setting) -> void:
    self._settings.add(setting)

func has_setting(key: StringName) -> bool:
    return self._settings.has_setting(key)

func get_setting(key: StringName) -> Setting:
    return self._settings.get_setting(key)

func remove(key: StringName) -> void:
    self._settings.remove(key)

func get_section(section: String, level_limit: int = -1) -> Array[Setting]:
    return self._settings.get_section(section, level_limit)

func get_section_names(parent_section: String = "") -> PackedStringArray:
    return self._settings.get_section_names(parent_section)

func apply_all() -> void:
    self._settings.apply_all()

func apply_pending() -> void:
    self._settings.apply_pending()

func clear_pending() -> void:
    self._settings.clear_pending()

func has_pending() -> bool:
    return self._settings.has_pending()

## filter: Callable[[Setting], bool]
func to_config(filter: Callable = Callable()) -> ConfigFile:
    return self._settings.to_config(filter)

func load_config(config: ConfigFile) -> void:
    self._settings.load_config(config)

func _on_applied(key: StringName) -> void:
    self._settings_applied = true
    self.applied.emit(key)

func _on_changed(key: StringName) -> void:
    self._settings_changed = true
    self.changed.emit(key)

func _on_pending_changed(key: StringName) -> void:
    self._settings_pending_changed = true
    self.pending_changed.emit(key)
