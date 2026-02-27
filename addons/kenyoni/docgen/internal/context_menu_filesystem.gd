extends EditorContextMenuPlugin

func _popup_menu(paths: PackedStringArray) -> void:
    if paths.size() == 1 && paths[0].get_extension() == "gd":
        self.add_context_menu_item("Generate documentation", self._on_single_ctx_menu_clicked)

func _on_single_ctx_menu_clicked(paths: PackedStringArray) -> void:
    if paths.size() != 1 || paths[0].get_extension() != "gd":
        return
    
    var path := paths[0]
    var script: Script = load(path)

    print("Generating documentation for script: %s" % path)
    for meth: Dictionary in script.get_method_list():
        print("method: %s" % meth["name"])
        print("  - {key}: {value}".format({"key": "args", "value": meth["args"]}))
