@tool
extends EditorPlugin

const ContextMenuFilesystem := preload("res://addons/kenyoni/docgen/internal/context_menu_filesystem.gd")

var _context_menu_filesystem: ContextMenuFilesystem

func _enter_tree() -> void:
    self._context_menu_filesystem = ContextMenuFilesystem.new()
    self.add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, self._context_menu_filesystem)

func _exit_tree() -> void:
    self.remove_context_menu_plugin(self._context_menu_filesystem)
