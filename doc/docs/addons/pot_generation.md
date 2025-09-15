# POT Generation

POT generation with files, directories and filters.

[**Download**](https://github.com/kenyoni-software/godot-addons/releases/tag/latest)

The filters are applied as glob patterns, for example:

- `*.gd` to include all GDScript files
- `*.tscn` to include all scene files

You can split multiple patterns with commas, for example: `*.gd,*.tscn`.

## Compatibility

| Godot | Version  |
| ----- | -------- |
| 4.5   | >= 1.0.0 |
| 4.4   | >= 1.0.0 |
| 4.3   | >= 1.0.0 |
| 4.2   | >= 1.0.0 |

## Screenshot

![POT generation screenshot](pot_generation/pot_generation.png "POT Generation")

## Changelog

### 1.1.1

- Fix: Refresh tree when filter changed

### 1.1.0

- Keep translation files from the Godot POT generation, if the plugin has not yet any configuration
- Disable filter input on files

### 1.0.0

- Initial release
