extends CheckBox

const Setting := preload("res://addons/kenyoni/app_settings/setting.gd")

var _setting: Setting = null

func _ready() -> void:
    self.add_theme_color_override(&"font_color", Color.RED)
    AppSettings.settings_changed.connect(self._on_settings_changed)
    AppSettings.settings_pending_changed.connect(self._on_settings_pending_changed)
    self.pressed.connect(self._on_pressed)

func set_setting(setting: Setting) -> void:
    self._setting = setting
    self.text = self._setting.key().rsplit("/", 1)[-1].capitalize()
    # OR
    # label.text = self.tr(setting.key())
    self.set_pressed_no_signal(setting.value())
    self._update()

func _update() -> void:
    # handle clear pending
    var pending_value: Variant = self._setting.pending_value()
    if pending_value == null:
        self.set_pressed_no_signal(self._setting.value())
    # colorize pending settings
    # better use a theme variant
    if self._setting.is_pending():
        self.add_theme_color_override(&"font_color", Color.YELLOW)
        self.add_theme_color_override(&"font_focus_color", Color.YELLOW.lightened(0.1))
        self.add_theme_color_override(&"font_pressed_color", Color.YELLOW.lightened(0.2))
        self.add_theme_color_override(&"font_hover_color", Color.YELLOW.lightened(0.15))
        self.add_theme_color_override(&"font_hover_pressed_color", Color.YELLOW.lightened(0.2))
        self.add_theme_color_override(&"font_disabled_color", Color.YELLOW)
    else:
        self.remove_theme_color_override(&"font_color")
        self.remove_theme_color_override(&"font_focus_color")
        self.remove_theme_color_override(&"font_pressed_color")
        self.remove_theme_color_override(&"font_hover_color")
        self.remove_theme_color_override(&"font_hover_pressed_color")
        self.remove_theme_color_override(&"font_disabled_color")

func _on_settings_changed() -> void:
    if self._setting == null:
        return
    self.set_pressed_no_signal(self._setting.value())
    self._update()

func _on_settings_pending_changed() -> void:
    if self._setting == null:
        return
    self._update()

func _on_pressed() -> void:
    if self._setting == null:
        return
    self._setting.set_value(self.button_pressed)
