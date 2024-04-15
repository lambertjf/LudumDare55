class_name Player extends CharacterBody3D

@export_category("Player")
@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 10.0, 0.1, "or_greater") var camera_sens: float = 1

var jumping: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3
var grav_vel: Vector3
var jump_vel: Vector3
var hit_vel: Vector3

var hit_power = 20.0
var just_hit = false

@onready var camera: Camera3D = $Camera3D
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
var hurt_sounds = [
	preload('res://assets/hurt1.ogg'),
	preload('res://assets/hurt2.ogg'),
	preload('res://assets/hurt3.ogg'),
]

var jump_sound = preload("res://assets/jump.ogg")

var recovery_time = 1.0
var recovering = false
@onready var rec_timer = $RecoveryTimer
var enemy_dir: Vector3

func _on_recovery_timer_timeout():
	recovering = false

func hit_by_enemy(enemy):
	if not recovering:
		audio.stream = hurt_sounds.pick_random()
		audio.play()
		enemy_dir = enemy.global_position.direction_to(global_position).normalized()
		enemy_dir.y = 0
		recovering = true
		just_hit = true
		rec_timer.start(recovery_time)

func _ready() -> void:
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed("jump"): jumping = true
	if not mouse_captured:
		if Input.is_action_just_pressed("shoot"): capture_mouse()
	if Input.is_action_just_pressed("exit"): release_mouse()
	if Input.is_action_just_pressed("quit"): get_tree().quit()
	

func _physics_process(delta: float) -> void:
	if mouse_captured: _handle_joypad_camera_rotation(delta)
	velocity = _walk(delta) + _gravity(delta) + _jump(delta) + _hit(delta)
	move_and_slide()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	if walk_vel.x != 0:
		camera.rotation.z = move_toward(camera.rotation.z, move_dir.x * -0.05, 0.001)
	else:
		camera.rotation.z = move_toward(camera.rotation.z, 0, 0.001)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel
	
func _hit(delta: float) -> Vector3:
	if just_hit:
		just_hit = false
		hit_vel = enemy_dir * hit_power
		hit_vel.y = sqrt(4 * jump_height * gravity) / 2
		return hit_vel
	hit_vel = Vector3.ZERO if is_on_floor() else hit_vel.move_toward(Vector3.ZERO, gravity * delta)
	return hit_vel
