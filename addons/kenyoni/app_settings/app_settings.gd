extends RefCounted

const Setting := preload("res://addons/kenyoni/app_settings/setting.gd")

## Emitted when any setting has been applied.
## `key` is the StringName of the applied setting.
signal applied(key: StringName)
## Emitted when any setting's effective value has changed.
## `key` is the StringName of the changed setting.
signal changed(key: StringName)
## Emitted when any staged value has changed or been cleared.
## `key` is the StringName of the setting whose staged value changed.
signal staged_changed(key: StringName)

# TODO: use a tree like structure to store settings
var _settings: Dictionary[StringName, Setting] = {}

## Add a new setting to the manager.
## Throw an error if the key is invalid or already exists.
func add(setting: Setting) -> void:
    if setting.key().ends_with("/") || setting.key().contains("//"):
        push_error("Setting keys should not end with a slash or contain an empty section.")
        return
    if !self.has_setting(setting.key()):
        self._settings[setting.key()] = setting
        setting.applied.connect(self._on_setting_applied.bind(setting))
        setting.changed.connect(self._on_setting_changed.bind(setting))
        setting.staged_changed.connect(self._on_setting_staged_changed.bind(setting))
    else:
        push_error("Setting with key '%s' already exists.".format(setting.key()))

## Return true if a setting with the given key exists.
func has_setting(key: StringName) -> bool:
    return self._settings.has(key)

## Return the setting for the given key, or null if it does not exist.
func get_setting(key: StringName) -> Setting:
    return self._settings.get(key, null)

## Remove a setting from the manager by its key.
func remove(key: StringName) -> void:
    var setting: Setting = self.get_setting(key)
    if setting != null:
        setting.applied.disconnect(self._on_setting_applied)
        setting.changed.disconnect(self._on_setting_changed)
        setting.staged_changed.disconnect(self._on_setting_staged_changed)
        self._settings.erase(key)

## Return all settings within a section.
## - `section` is a key prefix.
## - `depth` controls how deep in the hierarchy to include settings (-1 for all).
## - `filter` Callable[[Setting], bool] can be used to include only specific settings.
func get_section(section: String, depth: int = -1, filter: Callable = _exclude_internal) -> Array[Setting]:
    assert(!section.ends_with("/"), "key should not end with a slash")
    var section_level: int = _get_key_level(section)
    if section != "":
        section += "/"
    var settings: Array[Setting] = self._settings.values().filter(func(s: Setting): return s.key().begins_with(section) && (depth == -1 || (depth != -1 && _get_key_level(s.key()) == section_level + depth + 1)))
    if filter.is_valid():
        settings = settings.filter(filter)
    return settings

## Return the names of subsections within a section.
## - `parent_section` is the key prefix of the parent section.
## - `filter` Callable[[Setting], bool] can be used to include only specific settings.
func get_section_names(parent_section: String = "", filter: Callable = _exclude_internal) -> PackedStringArray:
    var sub_section_level: int = _get_key_level(parent_section)
    if parent_section != "":
        sub_section_level += 1
    if parent_section != "":
        parent_section += "/"

    var seen: Dictionary[String, bool] = {}
    var sections: PackedStringArray = PackedStringArray()
    var settings: Array[Setting] = self._settings.values()
    if filter.is_valid():
        settings = settings.filter(filter)
    for setting: Setting in settings:
        if !setting.key().begins_with(parent_section) || _get_key_level(setting.key()) <= sub_section_level:
            continue
        var sub_section_name: String = _get_key_part(setting.key(), sub_section_level)
        if !seen.has(sub_section_name):
            seen[sub_section_name] = true
            sections.append(sub_section_name)
    return sections

## Apply all settings immediately.
func apply_all() -> void:
    for setting: Setting in self._settings.values():
        setting.apply()

## Apply only staged values.
func apply_staged_values() -> void:
    for setting: Setting in self._settings.values():
        if setting._has_staged_value:
            setting.apply()

## Clear all staged values.
func clear_staged_values() -> void:
    for setting: Setting in self._settings.values():
        if setting.has_staged_value():
            setting.clear_staged_value()

## Return true if any settings have staged values.
func has_staged_values() -> bool:
    for setting: Setting in self._settings.values():
        if setting.has_staged_value():
            return true
    return false

## Set values from a ConfigFile.
func set_config(config: ConfigFile) -> void:
    for section: String in config.get_sections():
        for key: String in config.get_section_keys(section):
            var setting: Setting = self.get_setting(section.path_join(key))
            if setting == null:
                push_warning("Setting '%s/%s' not found.".format(section, key))
                continue
            # checking readonly is duplicated here, but it might be possible that set_value might push a warning when trying to set a readonly setting
            if setting.is_exported() && !setting.is_readonly():
                setting.set_value(config.get_value(section, key))

## Convert exported settings to a ConfigFile.
## - `filter` Callable[[Setting], bool] can be used to include only specific settings.
func to_config(filter: Callable = _include_exported) -> ConfigFile:
    var config: ConfigFile = ConfigFile.new()
    for key: StringName in self._settings:
        var setting: Setting = self.get_setting(key)
        if filter.is_valid() && !filter.call(setting):
            continue
        if _get_key_level(key) > 0:
            var keys: PackedStringArray = key.rsplit("/", true, 1)
            config.set_value(keys[0], keys[1], setting.value())
        else:
            config.set_value("", key, setting.value())
    return config

func _on_setting_applied(setting: Setting) -> void:
    self.applied.emit(setting.key())

func _on_setting_changed(setting: Setting) -> void:
    self.changed.emit(setting.key())

func _on_setting_staged_changed(setting: Setting) -> void:
    self.staged_changed.emit(setting.key())

static func _get_key_level(key: StringName) -> int:
    return key.count("/")

static func _get_key_part(key: StringName, level: int) -> String:
    var start := 0
    var count := 0

    for idx: int in key.length():
        if str(key)[idx] == "/":
            if count == level:
                return key.substr(start, idx - start)
            start = idx + 1
            count += 1

    if count == level:
        return key.substr(start)
    return ""

static func _exclude_internal(setting: Setting) -> bool:
    return !setting.is_internal()

static func _include_exported(setting: Setting) -> bool:
    return setting.is_exported()
