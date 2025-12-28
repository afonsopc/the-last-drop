extends Node3D

@onready var bus = $Bus
@onready var player = $Player

@export var player_bus_offset := Vector3(1, 0.8, 1.2)

func _ready() -> void:
	run_cutscene()

func run_cutscene() -> void:
	# Engine.time_scale = 50.0
	start_cutscene({"dont_play_air_brake_sound": true})
	await get_tree().create_timer(5.0, false).timeout
	player.showMessage("intro", "I really need to pee... maybe I'll ask the driver to stop.")
	await get_tree().create_timer(5.0, false).timeout
	player.hideMessage("intro")
	await get_tree().create_timer(2.5, false).timeout
	player.showMessage("intro", "You: Hello? Driver?")
	await get_tree().create_timer(2.0, false).timeout
	player.showMessage("intro2", "You: Can we stop at the next restroom?")
	await get_tree().create_timer(5.0, false).timeout
	player.hideMessage("intro")
	player.hideMessage("intro2")
	await get_tree().create_timer(2.5, false).timeout
	player.showMessage("intro", "Bus Driver: Sure.")
	await get_tree().create_timer(2.5, false).timeout
	player.showMessage("intro2", "Bus Driver: There's a restroom just ahead.")
	await get_tree().create_timer(5.0, false).timeout
	player.hideMessage("intro2")
	player.hideMessage("intro")
	await get_tree().create_timer(3.0, false).timeout
	player.showMessage("intro", "You: Ok, thanks!")
	await get_tree().create_timer(3.0, false).timeout
	player.hideMessage("intro")
	await get_tree().create_timer(1.0, false).timeout
	end_cutscene()

func start_cutscene(options = {}) -> void:
	if not options.has("dont_play_air_brake_sound") or not options["dont_play_air_brake_sound"]:
		bus.play_air_brake_sound()
	player.stop_background_sound()
	player.can_move = false
	player.set_camera_y(90)
	player.horizontal_look_range = Vector2(0, 180)
	player.get_parent().remove_child(player)
	bus.add_child(player)
	player.set_collision_layer(0)
	player.set_collision_mask(0)
	player.transform.origin = player_bus_offset
	bus.moving = true

func end_cutscene() -> void:
	# Engine.time_scale = 1.0
	player.play_background_sound()
	bus.play_air_brake_sound()
	bus.moving = false
	bus.remove_child(player)
	add_child(player)
	player.set_collision_layer(1)
	player.set_collision_mask(1)
	player.can_move = true
	player.transform.origin = bus.transform.origin + Vector3(0, 0, -3)
	player.horizontal_look_range = Vector2(-INF, INF)
	player.set_camera_y(45)
	player.showMessage("intro", "I really really need to pee...")
	await get_tree().create_timer(3.0).timeout
	player.hideMessage("intro")
