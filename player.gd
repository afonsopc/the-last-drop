extends CharacterBody3D

const BASE_SPEED = 3.3
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.1

@onready var footsteps_sound = $FootstepsSound
@onready var background_sound = $BackgroundSound
@onready var air_brake_sound = $AirBrakeSound
@onready var hand_washing_sound = $HandWashingSound
@onready var camera_pivot = $"Camera Pivot"
@onready var pee_sound = $PeeSound
@onready var game_over_label = $UI/GameOverLabel
@onready var message_label = $UI/MessageLabel
@onready var game_over_background = $UI/GameOverBackground
@onready var game_over_timer = $GameOverTimer
@onready var the_end_label = $UI/TheEndLabel
@onready var menu = $UI/Menu

var rotation_x = 0.0
var rotation_y := 0.0
var can_move := true
var can_look := true
var started_footsteps_sound := false
var in_pee_area := false
var in_hand_wash_area := false
var in_bathroom_exit_area := false
var in_bus_area := false
var has_peed := false
var has_washed_hands := false
var showed_station_message := false
var active_messages := {}
var paused := false

@export var vertical_look_range := Vector2(-60.0, 75.0)
@export var horizontal_look_range := Vector2(-INF, INF)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	menu.process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event is InputEventKey:
		if event.keycode == Key.KEY_ESCAPE and event.pressed:
			toggle_pause()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		handle_mouse_motion(event)
		
func _physics_process(delta: float) -> void:
	if not can_move:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	# if Input.is_action_just_pressed("player_jump") and is_on_floor():
	# 	velocity.y = JUMP_VELOCITY
	
	if in_pee_area and not has_peed:
		showMessage("pee_prompt", "Press 'E' to pee")
		if Input.is_action_just_pressed("player_action"):
			pee()
	else:
		hideMessage("pee_prompt")
	
	if in_hand_wash_area and has_peed and not has_washed_hands:
		showMessage("hand_wash_prompt", "Press 'E' to wash your hands")
		if Input.is_action_just_pressed("player_action"):
			wash_hands()
	else:
		hideMessage("hand_wash_prompt")
	
	if in_bus_area and has_peed and has_washed_hands:
		showMessage("bus_prompt", "Press 'E' to return to the bus")
		if Input.is_action_just_pressed("player_action"):
			run_end_cutscene()
			hideMessage("bus_prompt")
	else:
		hideMessage("bus_prompt")

	if in_bathroom_exit_area and has_peed:
		bathroom_after_pee_exit()

	var speed = BASE_SPEED
	# if Input.is_action_pressed("player_sprint"):
	# 	speed *= 5
	var input_dir := Input.get_vector("player_left", "player_right", "player_up", "player_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	var is_moving := velocity.length() > 0.1

	if not started_footsteps_sound:
		footsteps_sound.play()
		started_footsteps_sound = true
	footsteps_sound.stream_paused = not (is_on_floor() and is_moving and can_move)
	move_and_slide()

func handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if not can_look:
		return
	rotate_camera_y(-event.relative.x * MOUSE_SENSITIVITY)
	rotate_camera_x(-event.relative.y * MOUSE_SENSITIVITY)

func rotate_camera_x(angle: float) -> void:
	var new_rotation_x = clamp(
		rotation_x + angle,
		vertical_look_range[0],
		vertical_look_range[1]
	)
	set_camera_x(new_rotation_x)

func set_camera_y(angle: float) -> void:
	rotation_y = angle
	rotation_degrees.y = angle

func set_camera_x(angle: float) -> void:
	rotation_x = angle
	camera_pivot.rotation_degrees.x = angle

func rotate_camera_y(angle: float) -> void:
	var new_rotation_y = clamp(
		rotation_y + angle,
		horizontal_look_range[0],
		horizontal_look_range[1]
	)
	set_camera_y(new_rotation_y)


func _on_pee_area_body_entered(body: Node3D) -> void:
	if body != self:
		return
	in_pee_area = true


func _on_pee_area_body_exited(body: Node3D) -> void:
	if body != self:
		return
	in_pee_area = false

func _on_bathroom_exit_area_body_entered(body: Node3D) -> void:
	if body != self:
		return
	in_bathroom_exit_area = true

func _on_bathroom_exit_area_body_exited(body: Node3D) -> void:
	if body != self:
		return
	in_bathroom_exit_area = false

func _on_hand_wash_area_body_entered(body: Node3D) -> void:
	if body != self:
		return
	in_hand_wash_area = true


func _on_hand_wash_area_body_exited(body: Node3D) -> void:
	if body != self:
		return
	in_hand_wash_area = false

func _on_bus_area_body_entered(body: Node3D) -> void:
	if body != self:
		return
	in_bus_area = true

func _on_bus_area_body_exited(body: Node3D) -> void:
	if body != self:
		return
	in_bus_area = false

func _on_station_area_body_entered(body: Node3D) -> void:
	if body != self:
		return
	if showed_station_message:
		return
	showed_station_message = true
	showMessage("station_empty", "This place is deserted... Where is everyone?")
	await get_tree().create_timer(3.0).timeout
	hideMessage("station_empty")

func run_end_cutscene() -> void:
	get_tree().current_scene.start_cutscene()
	await get_tree().create_timer(15.0).timeout
	game_over_background.modulate.a = 0.0
	game_over_background.visible = true
	var tween = create_tween()
	tween.tween_property(game_over_background, "modulate:a", 1.0, 2.0)
	await tween.finished
	the_end_label.visible = true
	await get_tree().create_timer(5.0).timeout
	go_to_menu()

func pee() -> void:
	hideMessage("pee_prompt")
	in_pee_area = false
	pee_sound.play()
	can_move = false
	can_look = false
	await get_tree().create_timer(7.0).timeout
	can_move = true
	can_look = true
	has_peed = true
	showMessage("pee_done", "You have peed!")
	await get_tree().create_timer(2.0).timeout
	hideMessage("pee_done")

func bathroom_after_pee_exit() -> void:
	if not has_washed_hands:
		game_over("You left without washing your hands!")
		return
	showMessage("bathroom_exit", "I really should go back to the bus.")
	await get_tree().create_timer(3.0).timeout
	hideMessage("bathroom_exit")

func wash_hands() -> void:
	has_washed_hands = true
	hideMessage("hand_wash_prompt")
	hand_washing_sound.play()
	can_move = false
	can_look = false
	await get_tree().create_timer(3.0).timeout
	can_move = true
	can_look = true
	showMessage("hand_wash_done", "You have washed your hands!")
	await get_tree().create_timer(2.0).timeout
	hideMessage("hand_wash_done")

func play_background_sound() -> void:
	if not background_sound.playing:
		background_sound.play()

func stop_background_sound() -> void:
	if background_sound.playing:
		background_sound.stop()

func game_over(reason: String) -> void:
	game_over_background.visible = true
	showMessage("game_over", reason)
	game_over_label.visible = true
	can_move = false
	game_over_timer.start()
	game_over_timer.timeout.connect(go_to_menu)

func go_to_menu() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")

func showMessage(id: String, text: String) -> void:
	if active_messages.has(id):
		var existing_label = active_messages[id]
		existing_label.text = text
		existing_label.visible = true
		return
	
	var new_label = message_label.duplicate()
	new_label.text = text
	new_label.visible = true
	
	message_label.get_parent().add_child(new_label)
	
	var offset = active_messages.size() * 20
	new_label.position.y = message_label.position.y + offset
	
	active_messages[id] = new_label

func hideMessage(id: String) -> void:
	if active_messages.has(id):
		var label = active_messages[id]
		label.queue_free()
		active_messages.erase(id)
		
		var index = 0
		for msg_id in active_messages:
			var label_node = active_messages[msg_id]
			label_node.position.y = message_label.position.y + (index * 20)
			index += 1

func toggle_pause() -> void:
	paused = not paused
	get_tree().paused = paused
	if paused:
		menu.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		menu.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_resume_game_pressed() -> void:
	toggle_pause()

func _on_back_to_menu_pressed() -> void:
	toggle_pause()
	go_to_menu()
