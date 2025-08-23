extends PanelContainer

const Setting := preload("res://addons/kenyoni/app_settings/setting.gd")
# instead of preloading you can register it as an autoload AFTER AppSettings
# this scripts registers all settings
const GameSettings := preload("res://examples/app_settings/game_settings.gd")
const SettingsContainer := preload("res://examples/app_settings/settings/container.gd")

@export var _settings_container: PackedScene
@export var _tab_container: TabContainer
@export var _apply_button: Button
@export var _cancel_button: Button

func _ready() -> void:
    AppSettings.settings_applied.connect(self._on_settings_applied)
    AppSettings.settings_changed.connect(self._on_settings_changed)
    AppSettings.settings_staged_changed.connect(self._on_settings_staged_changed)
    # connecting to applied, changed and staged_changed signals can lead to performance issues
    # they will be emitted immediately after the setting is applied, changed or staged changed
    AppSettings.applied.connect(self._on_setting_applied)
    AppSettings.changed.connect(self._on_setting_changed)
    AppSettings.staged_changed.connect(self._on_setting_staged_changed)

    self._apply_button.pressed.connect(self._on_apply_button_pressed)
    self._cancel_button.pressed.connect(self._on_cancel_button_pressed)

    self._setup_settings()

# this will create settings with the following structure:
# section/sub_section/key
# each section is a tab container
# each sub_section will be a new titled label
func _setup_settings() -> void:
    var sections: PackedStringArray = AppSettings.get_section_names()
    for idx: int in range(len(sections)):
        var section: String = sections[idx]

        var container: SettingsContainer = self._settings_container.instantiate()
        self._tab_container.add_child(container)
        self._tab_container.set_tab_title(idx, section.capitalize())
        # OR
        # self._tab_container.set_tab_title(idx, self.tr("section_" + section))

        # all settings in section without a sub section
        for setting: Setting in AppSettings.get_section(section, 0):
            container.add_setting(setting)
        # add all sub sections and their settings
        for sub_section: String in AppSettings.get_section_names(section):
            container.add_section(sub_section.capitalize())
            for setting: Setting in AppSettings.get_section(section.path_join(sub_section)):
                container.add_setting(setting)

func _on_apply_button_pressed() -> void:
    AppSettings.apply_staged_values()
    print(AppSettings.to_config().encode_to_text())

func _on_cancel_button_pressed() -> void:
    AppSettings.clear_staged_values()

func _on_settings_applied() -> void:
    print("Setting applied")

func _on_settings_changed() -> void:
    print("Setting changed")

func _on_settings_staged_changed() -> void:
    print("Setting staged changed")
    self._apply_button.disabled = !AppSettings.has_staged_values()
    self._cancel_button.disabled = !AppSettings.has_staged_values()

func _on_setting_applied(key: String) -> void:
    print("'%s' applied" % key)

func _on_setting_changed(key: String) -> void:
    print("'%s' changed" % key)

func _on_setting_staged_changed(key: String) -> void:
    print("'%s' staged changed" % key)
