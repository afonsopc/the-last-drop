extends Node3D

@onready var exit_button = $ExitButton
@onready var start_button = $StartButton

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if OS.get_name() == "Web":
		exit_button.visible = false
		start_button.rect_position.x = (get_viewport().get_visible_rect().size.x - start_button.rect_size.x) / 2

func _unhandled_input(event):
	if event is InputEventKey:
		if event.keycode == Key.KEY_ESCAPE and event.pressed:
			get_tree().quit()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
