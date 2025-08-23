
@tool
extends EditorPlugin

func _enable_plugin() -> void:
    self.add_autoload_singleton("AppSettings", "res://addons/kenyoni/app_settings/g_app_settings.gd")

func _disable_plugin() -> void:
    self.remove_autoload_singleton("AppSettings")
