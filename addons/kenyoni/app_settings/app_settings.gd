extends RefCounted

const Setting := preload("res://addons/kenyoni/app_settings/setting.gd")

signal applied(key: StringName)
signal changed(key: StringName)
signal pending_changed(key: StringName)

# TODO: use a tree like structure to store settings
var _settings: Dictionary[StringName, Setting] = {}

func add(setting: Setting) -> void:
    if setting.key().ends_with("/") || setting.key().contains("//"):
        push_error("Setting keys should not end with a slash or contain an empty section.")
        return
    if !self.has_setting(setting.key()):
        self._settings[setting.key()] = setting
        setting.applied.connect(self._on_setting_applied.bind(setting))
        setting.changed.connect(self._on_setting_changed.bind(setting))
        setting.pending_changed.connect(self._on_setting_pending_changed.bind(setting))
    else:
        push_error("Setting with key '%s' already exists.".format(setting.key()))

func has_setting(key: StringName) -> bool:
    return self._settings.has(key)

## returns null if the setting does not exist
func get_setting(key: StringName) -> Setting:
    return self._settings.get(key, null)

func remove(key: StringName) -> void:
    var setting: Setting = self.get_setting(key)
    if setting != null:
        setting.applied.disconnect(self._on_setting_applied)
        setting.changed.disconnect(self._on_setting_changed)
        setting.pending_changed.disconnect(self._on_setting_pending_changed)
        self._settings.erase(key)

## if level_limit is >= 0 it will only return the settings that are level_limit below or less. Otherwise it will return all settings in the section.
## 0 is just the settings in that section.
## filter: Callable[[Setting], bool]
func get_section(section: String, level_limit: int = -1, filter: Callable = _exclude_internal) -> Array[Setting]:
    assert(!section.ends_with("/"), "key should not end with a slash")
    var section_level: int = _get_key_level(section)
    if section != "":
        section += "/"
    var settings: Array[Setting] = self._settings.values().filter(func(s: Setting): return s.key().begins_with(section) && (level_limit == -1 || (level_limit != -1 && _get_key_level(s.key()) == section_level + level_limit + 1)))
    if filter.is_valid():
        settings = settings.filter(filter)
    return settings

## returns the names of that section
## will not include keys last names
## filter: Callable[[Setting], bool]
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

func apply_all() -> void:
    for setting: Setting in self._settings.values():
        setting.apply()

func apply_pending() -> void:
    for setting: Setting in self._settings.values():
        if setting._is_pending:
            setting.apply()

func clear_pending() -> void:
    for setting: Setting in self._settings.values():
        if setting.is_pending():
            setting.clear_pending()

func has_pending() -> bool:
    for setting: Setting in self._settings.values():
        if setting.is_pending():
            return true
    return false

## filter: Callable[[Setting], bool]
func to_config(filter: Callable = Callable()) -> ConfigFile:
    var config: ConfigFile = ConfigFile.new()
    for key: StringName in self._settings:
        var setting: Setting = self.get_setting(key)
        if !setting.is_exported() || filter.is_valid() && !filter.call(setting):
            continue
        if _get_key_level(key) > 0:
            var keys: PackedStringArray = key.rsplit("/", true, 1)
            config.set_value(keys[0], keys[1], setting.value())
        else:
            config.set_value("", key, setting.value())
    return config

func load_config(config: ConfigFile) -> void:
    for section: String in config.get_sections():
        for key: String in config.get_section_keys(section):
            var value: Variant = config.get_value(section, key)
            if self.has_setting(section.path_join(key)):
                self.get_setting(section.path_join(key)).set_value(value)
            else:
                push_warning("Setting '%s/%s' not found.".format(section, key))

func _on_setting_applied(setting: Setting) -> void:
    self.applied.emit(setting.key())

func _on_setting_changed(setting: Setting) -> void:
    self.changed.emit(setting.key())

func _on_setting_pending_changed(setting: Setting) -> void:
    self.pending_changed.emit(setting.key())

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
