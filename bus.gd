extends Node3D

@export var speed := 6.5

@onready var engine_sound = $EngineSound
@onready var air_brake_sound = $AirBrakeSound

var moving := false

func _physics_process(delta: float) -> void:
	if not moving:
		engine_sound.stop()
		return
	if not engine_sound.playing:
		engine_sound.play()
	translate(Vector3(-speed * delta, 0, 0))

func play_air_brake_sound() -> void:
	if not air_brake_sound.playing:
		air_brake_sound.play()
