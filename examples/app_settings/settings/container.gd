extends ScrollContainer

const Setting := preload("res://addons/kenyoni/app_settings/setting.gd")

const BoolSetting := preload("res://examples/app_settings/settings/bool.gd")
const BoolSettingScene := preload("res://examples/app_settings/settings/bool.tscn")

@export var _container: VBoxContainer

func add_section(section: String) -> void:
    if self._container.get_child_count() > 0:
        var spacer: Control = Control.new()
        spacer.custom_minimum_size = Vector2(0, 32)
        self._container.add_child(spacer)
    var label: Label = Label.new()
    self._container.add_child(label)
    label.text = section
    label.theme_type_variation = &"HeaderLarge"
    self._container.add_child(HSeparator.new())

func add_setting(setting: Setting) -> void:
    match setting.get_meta("type", -1):
        TYPE_BOOL:
            var ui_setting: BoolSetting = BoolSettingScene.instantiate()
            self._container.add_child(ui_setting)
            ui_setting.set_setting(setting)
        _:
            var label: Label = Label.new()
            self._container.add_child(label)
            label.text = _get_setting_text(setting.key()) + " | " + str(setting.value())
    print(setting.key(), ": ", setting.value(), " - ", typeof(setting.value()), " | ", setting.value() is bool)

# fast fix way to get the setting text
static func _get_setting_text(key: StringName) -> String:
    return key.rsplit("/", 1)[-1].capitalize()
