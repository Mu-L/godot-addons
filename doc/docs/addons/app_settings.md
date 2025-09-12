# App Settings

An easy-to-use system for organizing, saving, and updating settings. With built-in support for staging changes and reacting to updates in real time.

This library provides:

- **Staged or immediate settings** with optional custom apply logic
- **Hierarchical keys** for organized grouping of settings and easy section queries.  
- **ConfigFile integration** for saving and loading settings.  
- **Signal-driven updates** to respond to changes in settings efficiently.  
- **Autoload-ready wrapper** for global access and frame-coalesced signal emission.  
- **Utilities** for filtering, section extraction, and internal setting management.  

[AppSettings (Node)](#appsettings-node): Autoload singleton wrapper for global access.  
[AppSettings](#appsettings): App settings manager class.  
[Setting](#setting): Class representing an individual setting.

[**Download**](https://github.com/kenyoni-software/godot-addons/releases)

## Compatibility

| Godot | Version |
| ----- | ------- |
| 4.5   | all     |

## Example

{{ kny:source "/examples/app_settings/" }}

## Interface

### AppSettings (Node)

{{ kny:badge extends RefCounted --left-bg }}

{{ kny:source "/addons/kenyoni/app_settings/g_app_settings.gd" "res://addons/kenyoni/app_settings/g_app_settings.gd" }}

This is a node wrapper around the [AppSettings](#appsettings) class for easy use as an autoload singleton. It provides additional signals.

#### Signals

| Name {: .kny-mono-font }                                              | Description                                                |
| --------------------------------------------------------------------- | ---------------------------------------------------------- |
| settings_applied() {: .kny-mono-font }                                  | Emitted once per frame if any settings were applied.                 |
| settings_changed() {: .kny-mono-font }                                  | Emitted once per frame if any effective setting values changed.      |
| settings_staged_changed() {: .kny-mono-font }                           | Emitted once per frame if any staged values changed or were cleared. |
| applied(key: {{ kny:godot StringName }}) {: .kny-mono-font }        | Emitted when any setting has been applied.                 |
| changed(key: {{ kny:godot StringName }}) {: .kny-mono-font }        | Emitted when any setting's effective value changes.        |
| staged_changed(key: {{ kny:godot StringName }}) {: .kny-mono-font } | Emitted when any staged value has changed or been cleared. |

#### Methods

void add(setting: [Setting](#setting)) {: .kny-mono-font }
:     Add a new setting to the manager. Throws an error if the key is invalid or already exists. Automatically connects the setting's signals.

{{ kny:godot bool }} has_setting(key: {{ kny:godot StringName }}) const {: .kny-mono-font }
:     Returns true if a setting with the given key exists.

[Setting](#setting) get_setting(key: {{ kny:godot StringName }}) const {: .kny-mono-font }
:     Returns the setting for the given key, or null if it does not exist.

void remove(key: {{ kny:godot StringName }}) {: .kny-mono-font }
:     Remove a setting from the manager by its key. Disconnects its signals and deletes it from internal storage.

{{ kny:godot Array }}[[Setting](#setting)] get_section(section: {{ kny:godot String }}, depth: {{ kny:godot int }}=-1, filter: {{ kny:godot Callable }}=_exclude_internal) const {: .kny-mono-font }
:     Return all settings within a section. Supports hierarchical depth filtering and optional filter Callable.

{{ kny:godot PackedStringArray }} get_section_names(parent_section: {{ kny:godot String }}="", filter: {{ kny:godot Callable }}=_exclude_internal) const {: .kny-mono-font }
:     Return the names of subsections within a section.

void apply_all() {: .kny-mono-font }
:     Apply all settings immediately.

void apply_staged_values() {: .kny-mono-font }
:     Apply only staged values.

void clear_staged_values() {: .kny-mono-font }
:     Clear all staged values.

{{ kny:godot bool }} has_staged_values() const {: .kny-mono-font }
:     Return true if any settings have staged values.

void set_config(config: {{ kny:godot ConfigFile }}) const {: .kny-mono-font }
:     Set values from a {{ kny:godot ConfigFile }}. Warns about settings that do not exist in the manager.

{{ kny:godot ConfigFile }} to_config(filter: {{ kny:godot Callable }}=_include_exported) const {: .kny-mono-font }
:     Convert exported settings to a {{ kny:godot ConfigFile }}. Optional filter Callable can exclude certain settings.

### AppSettings

{{ kny:badge extends RefCounted --left-bg }}

{{ kny:source "/addons/kenyoni/app_settings/app_settings.gd" "res://addons/kenyoni/app_settings/app_settings.gd" }}

Manager class for handling multiple [Setting](#setting) instances with hierarchical keys, staged changes, and ConfigFile integration.

#### Signals

| Name {: .kny-mono-font }                                              | Description                                                |
| --------------------------------------------------------------------- | ---------------------------------------------------------- |
| applied(key: {{ kny:godot StringName }}) {: .kny-mono-font }        | Emitted when any setting has been applied.                 |
| changed(key: {{ kny:godot StringName }}) {: .kny-mono-font }        | Emitted when any setting's effective value changes.        |
| staged_changed(key: {{ kny:godot StringName }}) {: .kny-mono-font } | Emitted when any staged value has changed or been cleared. |

#### Methods

void add(setting: [Setting](#setting)) {: .kny-mono-font }
:     Add a new setting to the manager. Throws an error if the key is invalid or already exists. Automatically connects the setting's signals.

{{ kny:godot bool }} has_setting(key: {{ kny:godot StringName }}) const {: .kny-mono-font }
:     Returns true if a setting with the given key exists.

[Setting](#setting) get_setting(key: {{ kny:godot StringName }}) const {: .kny-mono-font }
:     Returns the setting for the given key, or null if it does not exist.

void remove(key: {{ kny:godot StringName }}) {: .kny-mono-font }
:     Remove a setting from the manager by its key. Disconnects its signals and deletes it from internal storage.

{{ kny:godot Array }}[[Setting](#setting)] get_section(section: {{ kny:godot String }}, depth: {{ kny:godot int }}=-1, filter: {{ kny:godot Callable }}=_exclude_internal) const {: .kny-mono-font }
:     Return all settings within a section. Supports hierarchical depth filtering and optional filter Callable.

{{ kny:godot PackedStringArray }} get_section_names(parent_section: {{ kny:godot String }}="", filter: {{ kny:godot Callable }}=_exclude_internal) const {: .kny-mono-font }
:     Return the names of subsections within a section.

void apply_all() {: .kny-mono-font }
:     Apply all settings immediately.

void apply_staged_values() {: .kny-mono-font }
:     Apply only staged values.

void clear_staged_values() {: .kny-mono-font }
:     Clear all staged values.

{{ kny:godot bool }} has_staged_values() const {: .kny-mono-font }
:     Return true if any settings have staged values.

void set_config(config: {{ kny:godot ConfigFile }}) {: .kny-mono-font }
:     Load settings from a {{ kny:godot ConfigFile }}. Warns about settings that do not exist in the manager.

{{ kny:godot ConfigFile }} to_config(filter: {{ kny:godot Callable }}=_include_exported) const {: .kny-mono-font }
:     Convert exported settings to a {{ kny:godot ConfigFile }}. Optional filter Callable can exclude certain settings.

### Setting

{{ kny:badge extends RefCounted --left-bg }}

{{ kny:source "/addons/kenyoni/app_settings/setting.gd" "res://addons/kenyoni/app_settings/setting.gd" }}

Class representing a configurable application setting with support for staged changes, validation, and custom apply logic.

#### Signals

| Name {: .kny-mono-font }           | Description                                        |
| ---------------------------------- | -------------------------------------------------- |
| applied {: .kny-mono-font }        | Emitted when the value has been applied.           |
| changed {: .kny-mono-font }        | Emitted when the effective value changes.          |
| staged_changed {: .kny-mono-font } | Emitted when a staged value changes or is cleared. |

#### Methods

void set_value(new_value: {{ kny:godot Variant }}) {: .kny-mono-font }
:     Assign a new value. Respects staged mode and readonly status. Automatically validates the value.

{{ kny:godot Variant }} value() const {: .kny-mono-font }
:     Returns the current effective value, ignoring staged value.

{{ kny:godot StringName }} key() const {: .kny-mono-font }
:     Returns the key of this setting.

{{ kny:godot Variant }} default_value() const {: .kny-mono-font }
:     Returns the default value of this setting.

{{ kny:godot bool }} validate(value: {{ kny:godot Variant }}) {: .kny-mono-font }
:     Validate a candidate value using the custom validator (if defined).

void apply() {: .kny-mono-font }
:     Apply the current value. Moves staged value to effective value if needed and emits relevant signals.

void reset() {: .kny-mono-font }
:     Reset the setting to its default value. Does nothing if readonly.

[Setting](#setting) set_staged(staged: {{ kny:godot bool }}=true) {: .kny-mono-font }
:     Enable or disable staged mode. Clears pending staged value if disabling.

[Setting](#setting) set_validate_fn(fn: {{ kny:godot Callable }}) {: .kny-mono-font }
:     Set a custom validator function. Should return true for valid values.

[Setting](#setting) set_apply_fn(fn: {{ kny:godot Callable }}) {: .kny-mono-font }
:     Set a custom apply function. Called when `apply()` is executed.

{{ kny:godot bool }} is_staged_mode() const {: .kny-mono-font }
:     Return true if this setting is using staged mode.

{{ kny:godot bool }} has_staged_value() const {: .kny-mono-font }
:     Return true if a staged value exists.

void clear_staged_value() {: .kny-mono-font }
:     Clear any staged value. Emits `staged_changed` if a value was cleared.

{{ kny:godot Variant }} staged_value() const {: .kny-mono-font }
:     Returns the staged value, or null if none.

{{ kny:godot Variant }} staged_or_value() const {: .kny-mono-font }
:     Returns the staged value if present, otherwise the current effective value.

[Setting](#setting) set_readonly(readonly: {{ kny:godot bool }}=true) {: .kny-mono-font }
:     Mark this setting as readonly. Readonly settings cannot be changed via `set_value()` or `reset()`.

{{ kny:godot bool }} is_readonly() const {: .kny-mono-font }
:     Return true if the setting is readonly.

[Setting](#setting) set_internal(internal: {{ kny:godot bool }}=true) {: .kny-mono-font }
:     Mark this setting as internal (hidden from UI).

{{ kny:godot bool }} is_internal() const {: .kny-mono-font }
:     Return true if the setting is internal.

[Setting](#setting) set_exported(exported: {{ kny:godot bool }}=true) {: .kny-mono-font }
:     Mark this setting as exportable (saved to file).

{{ kny:godot bool }} is_exported() const {: .kny-mono-font }
:     Return true if the setting is exportable (default true).

[Setting](#setting) set_description(desc: {{ kny:godot String }}) {: .kny-mono-font }
:     Set a human-readable description.

{{ kny:godot String }} description() const {: .kny-mono-font }
:     Return the human-readable description.

[Setting](#setting) add_meta(meta_key: {{ kny:godot StringName }}, val: {{ kny:godot Variant }}) {: .kny-mono-font }
:     Add arbitrary metadata key/value.

## Changelog

### 1.0.0

- Initial release for Godot 4.5
