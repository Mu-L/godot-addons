extends RefCounted
class_name _KenyoniAppSettingSetting

## will be emitted when the value is applied
signal applied()
## emitted if a value is about to be applied and was different before
signal changed()
## if not staged, it won't be emitted
signal pending_changed()

var _value: Variant
## takes the object itself as first argument
## Callable[Setting]
var _apply_fn: Callable = Callable()
## takes the object itself as first argument and the new value as second argument
## should return true if the value is valid
## Callable[[Setting, Variant], bool]
var _validate_fn: Callable = Callable()
var _key: StringName
var _default_value: Variant = null

var _is_staged: bool = false
var _pending_value: Variant = null
var _is_pending: bool = false
var _is_readonly: bool = false

## default value will be set, but not applied
## passed values should give up owning of the object, aka. not use it after this call
func _init(key_: StringName, default_value_: Variant) -> void:
    self._key = key_
    self._default_value = default_value_
    self._value = default_value_

## apply_value has no effect if the setting is staged, if false it will not call apply
func set_value(new_value: Variant) -> void:
    if !self.validate(new_value):
        return
    self._set_value_no_validation(new_value)

func value() -> Variant:
    return self._value

func key() -> StringName:
    return self._key

func default_value() -> Variant:
    return self._default_value

func validate(value: Variant) -> bool:
    if self._validate_fn.is_valid():
        return self._validate_fn.call(self, value)
    return true

func apply() -> void:
    if self._is_pending:
        var is_different: bool = self._pending_value != self._value
        self._value = self._pending_value
        self._pending_value = null
        self._is_pending = false
        self.pending_changed.emit()
        if is_different:
            self.changed.emit()
    if self._apply_fn.is_valid():
        self._apply_fn.call(self)
    self.applied.emit()

## Revert the setting to its default value
func revert() -> void:
    self._set_value_no_validation(self._default_value)

## Side effect: turning staged off will also delete the pending value
func set_staged(staged: bool = true) -> _KenyoniAppSettingSetting:
    self._is_staged = staged
    if !staged:
        self.clear_pending()
    return self

func set_validate_fn(fn: Callable) -> _KenyoniAppSettingSetting:
    self._validate_fn = fn
    return self

func set_apply_fn(fn: Callable) -> _KenyoniAppSettingSetting:
    self._apply_fn = fn
    return self

func is_staged() -> bool:
    return self._is_staged

func is_pending() -> bool:
    return self._is_pending

func clear_pending() -> void:
    if !self._is_pending:
        return
    self._pending_value = null
    self._is_pending = false
    self.pending_changed.emit()

## returns null if not staged
func pending_value() -> Variant:
    return self._pending_value

func pending_or_value() -> Variant:
    if self._is_pending:
        return self._pending_value
    return self._value

## use this to mark the setting as readonly, it will not be editable, applying will still work
func set_readonly(readonly: bool = true) -> _KenyoniAppSettingSetting:
    self._is_readonly = readonly
    return self

func is_readonly() -> bool:
    return self._is_readonly

## Helper functions for setting metadata
## common metadata keys are the same as for the property_info
## type, hint, hint_string, ...
## min, max, step, etc. for numeric values
## values for enum values
## https://docs.godotengine.org/en/stable/classes/class_editorsettings.html#class-editorsettings-method-add-property-info

## mark setting as advanced, use to distinguish between normal and advanced settings
func set_advanced(advanced: bool = true) -> _KenyoniAppSettingSetting:
    self.set_meta(&"advanced", advanced)
    return self

func is_advanced() -> bool:
    return self.get_meta(&"advanced", false)

## mark setting as internal, not shown in the UI
func set_internal(internal: bool = true) -> _KenyoniAppSettingSetting:
    self.set_meta(&"internal", internal)
    return self

func is_internal() -> bool:
    return self.get_meta(&"internal", false)

## mark setting as not exportable, will not be saved to the settings file
func set_no_export(no_export: bool = false) -> _KenyoniAppSettingSetting:
    self.set_meta(&"exported", no_export)
    return self

func is_exported() -> bool:
    return self.get_meta(&"exported", true)

func set_description(desc: String) -> _KenyoniAppSettingSetting:
    self.set_meta(&"description", desc)
    return self

func description() -> String:
    return self.get_meta(&"description", "")

func add_meta(meta_key: StringName, val: Variant) -> _KenyoniAppSettingSetting:
    self.set_meta(meta_key, val)
    return self

func _set_value_no_validation(new_value: Variant) -> void:
    if self._is_readonly:
        return
    if self._value == new_value:
        if self._is_pending:
            self.clear_pending()
        return

    if self._is_staged:
        if self._pending_value == new_value:
            return
        self._pending_value = new_value
        self._is_pending = true
        self.pending_changed.emit()
        return

    self._value = new_value
    self.changed.emit()
    self.apply()
