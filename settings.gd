extends Node

# Autoload singleton. Holds game settings and persists them to disk.
# Access from anywhere as: Settings.mouse_sensitivity

const SAVE_PATH := "user://settings.cfg"

var mouse_sensitivity := 0.1

func _ready() -> void:
	load_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	config.save(SAVE_PATH)

func load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err != OK:
		return  # no file yet (first run) → keep defaults
	mouse_sensitivity = config.get_value("controls", "mouse_sensitivity", mouse_sensitivity)
