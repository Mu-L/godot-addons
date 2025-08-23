extends RefCounted
class_name _KenyoniAppSettingSetting

## Emitted when the value has been applied.
signal applied()
## Emitted when the effective value changes.
## This signal is only fired when the effective value changes.
signal changed()
## Emitted when a staged value changes or is cleared.
## The staged value is only used if the setting is staged.
signal staged_changed()

## Current effective value.
var _value: Variant
## Callable executed on apply.
## Callable[[Setting]]
var _apply_fn: Callable = Callable()
## Callable executed to validate new values.
## Should return true if the new value is considered valid.
## Callable[[Setting, Variant], bool]
var _validate_fn: Callable = Callable()
## Unique identifier (hierarchical, e.g. "graphics/display/fullscreen").
var _key: StringName
## The default value, used for reset().
var _default_value: Variant = null

## Whether the setting is staged (values go into staged until applied).
var _is_staged: bool = false
## Holds the staged value until applied.
var _staged_value: Variant = null
var _has_staged_value: bool = false
## Setting cannot be changed if readonly.
var _is_readonly: bool = false

## Create a new setting with key and default value.
## The default is assigned as the current value but not applied.
func _init(key_: StringName, default_value_: Variant) -> void:
    self._key = key_
    self._default_value = default_value_
    self._value = default_value_

## Assign a new value.
## - If staged, the value is stored as staged until apply() is called.
## - If not staged, the value is immediately set, validated, and applied.
## - If readonly, the assignment is ignored.
func set_value(new_value: Variant) -> void:
    if !self.validate(new_value):
        return
    self._set_value_no_validation(new_value)

## Return the current effective value (ignores staged).
func value() -> Variant:
    return self._value

## Return the key of this setting.
func key() -> StringName:
    return self._key

## Return the default value of this setting.
func default_value() -> Variant:
    return self._default_value

## Validate a candidate value using the custom validator (if defined).
func validate(value: Variant) -> bool:
    if self._validate_fn.is_valid():
        return self._validate_fn.call(self, value)
    return true

## Apply the current value.
## - If staged, moves it to the effective value and clears staged value.
## - Always calls the apply function if defined.
## - Always emits applied().
## - Emits changed() if the effective value actually changed.
## - Emits staged_changed() if a pending value was cleared.
func apply() -> void:
    if self._has_staged_value:
        var is_different: bool = self._staged_value != self._value
        self._value = self._staged_value
        self._staged_value = null
        self._has_staged_value = false
        self.staged_changed.emit()
        if is_different:
            self.changed.emit()
    if self._apply_fn.is_valid():
        self._apply_fn.call(self)
    self.applied.emit()

## Reset the setting to its default value.
## If readonly, this call has no effect.
func reset() -> void:
    self._set_value_no_validation(self._default_value)

## Enable/disable staged mode.
## - If disabling staged mode, any pending value is cleared.
func set_staged(staged: bool = true) -> _KenyoniAppSettingSetting:
    self._is_staged = staged
    if !staged:
        self.clear_staged_value()
    return self

## Set a custom validator function.
## fn: Callable[[Setting, Variant], bool]
func set_validate_fn(fn: Callable) -> _KenyoniAppSettingSetting:
    self._validate_fn = fn
    return self

## Set a custom apply function.
## fn: Callable[[Setting]]
func set_apply_fn(fn: Callable) -> _KenyoniAppSettingSetting:
    self._apply_fn = fn
    return self

## Return true if this setting is using staged mode.
func is_staged_mode() -> bool:
    return self._is_staged

## Return true if this setting has a staged value.
func has_staged_value() -> bool:
    return self._has_staged_value

## Clear any staged value.
## Emit staged_changed() if a staged value was cleared.
func clear_staged_value() -> void:
    if !self._has_staged_value:
        return
    self._staged_value = null
    self._has_staged_value = false
    self.staged_changed.emit()

## Return the staged value, or null if none.
func staged_value() -> Variant:
    return self._staged_value

## Return the staged value if present, otherwise the current value.
func staged_or_value() -> Variant:
    if self._has_staged_value:
        return self._staged_value
    return self._value

## Mark this setting as readonly.
## Readonly settings cannot be changed via set_value() or reset().
func set_readonly(readonly: bool = true) -> _KenyoniAppSettingSetting:
    self._is_readonly = readonly
    return self

## Return true if the setting is readonly.
func is_readonly() -> bool:
    return self._is_readonly

## Metadata helpers
## Common metadata keys follow Godot's property_info (type, hint, etc.)
## https://docs.godotengine.org/en/stable/classes/class_editorsettings.html#class-editorsettings-method-add-property-info

## Mark this setting as internal (hidden from UI).
func set_internal(internal: bool = true) -> _KenyoniAppSettingSetting:
    self.set_meta(&"internal", internal)
    return self

func is_internal() -> bool:
    return self.get_meta(&"internal", false)

## Mark this setting as exportable (saved to file).
func set_exported(exported: bool = true) -> _KenyoniAppSettingSetting:
    self.set_meta(&"exported", exported)
    return self

## Return true if the setting is exportable (saved to file). It is true by default.
func is_exported() -> bool:
    return self.get_meta(&"exported", true)

## Set a human-readable description.
func set_description(desc: String) -> _KenyoniAppSettingSetting:
    self.set_meta(&"description", desc)
    return self

func description() -> String:
    return self.get_meta(&"description", "")

## Add arbitrary metadata key/value.
func add_meta(meta_key: StringName, val: Variant) -> _KenyoniAppSettingSetting:
    self.set_meta(meta_key, val)
    return self

## Internal setter that skips validation.
## - Respects readonly.
## - If staged, sets as pending instead.
## - If not staged, assigns immediately, emits changed(), then calls apply().
func _set_value_no_validation(new_value: Variant) -> void:
    if self._is_readonly:
        return
    if self._value == new_value:
        if self._has_staged_value:
            self.clear_staged_value()
        return

    if self._is_staged:
        if self._staged_value == new_value:
            return
        self._staged_value = new_value
        self._has_staged_value = true
        self.staged_changed.emit()
        return

    self._value = new_value
    self.changed.emit()
    self.apply()
