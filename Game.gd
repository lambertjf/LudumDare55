extends Node3D

var enemy_scene = preload('res://enemy.tscn')

@onready var player = $Player
@onready var level_container = $LevelContainer
@onready var summon_hand = $Player/LeftHand
@onready var env = $WorldEnvironment
@onready var lava = $DeathBox/Waves
@onready var lava_b = $DeathBox/Bottom
@onready var death_screen = $UI/Death
@onready var spawn_timer = $SpawnTimer
@onready var playtime_label = $UI/Playtime

var death_sound = preload("res://assets/death.ogg")
var levels = [
	preload('res://levels/level_1.tscn'),
	preload('res://levels/level_2.tscn'),
	preload('res://levels/level_3.tscn'),
	preload('res://levels/level_4.tscn'),
	preload('res://levels/level_5.tscn')
]
var cur_level_idx = 0
var cur_level

var dying = false
var respawn_time = 3.0


var enemy_spawn_time = 0
var enemies = []
var enemy_y_spawn = 50.0
var minimum_spawn_time = 1.0

var seconds = 0.0
var minutes = 0
var gate_area
var changing_level = false

func format_playtime():
	return '{m}:{zero}{s}'.format({'m': minutes, 's': str(seconds).pad_decimals(2), 'zero': '0' if seconds < 10.0 else ''})

func win_state():
	print('You Win')
	Global.completion_time = format_playtime()
	get_tree().change_scene_to_file('res://win_screen.tscn')

func gate_entered():
	print('gate')
	cur_level_idx += 1
	if cur_level_idx < len(levels):
		set_level(cur_level_idx)
	else:
		win_state()

func set_level(level_num):
	print(level_num)
	for l in level_container.get_children():
		level_container.remove_child(l)
		l.queue_free()
	cur_level = levels[level_num].instantiate()
	level_container.add_child(cur_level)
	reset()
	init_level()
	changing_level = false

func reset():
	enemy_spawn_time = cur_level.enemy_spawn_time_base
	for e in enemies:
		if is_instance_valid(e):
			e.queue_free()
	enemies = []
	summon_hand.reset_platforms()
	player.global_position = cur_level.get_node('PlayerSpawn').global_position

func spawn_enemy():
	var new_enemy = enemy_scene.instantiate()
	enemies.append(new_enemy)
	add_child(new_enemy)
	
	var random_x = randf_range(25, 100)
	var random_z = randf_range(25, 10)
	if randi_range(0, 1) == 1:
		random_x *= -1
	if randi_range(0, 1) == 1:
		random_z *= -1

	new_enemy.global_position = gate_area.global_position + Vector3(random_x, enemy_y_spawn, random_z)

func _on_spawn_timer_timeout():
	spawn_enemy()
	if enemy_spawn_time > minimum_spawn_time:
		enemy_spawn_time *= cur_level.time_mod
	spawn_timer.start(enemy_spawn_time)

func init_level():
	env.environment.sky.sky_material.sky_top_color = cur_level.sky
	env.environment.sky.sky_material.sky_horizon_color = cur_level.sky_hor
	env.environment.sky.sky_material.ground_bottom_color = cur_level.waves_high
	env.environment.sky.sky_material.ground_horizon_color = cur_level.waves_high.lerp(cur_level.waves_low, 0.5)
	
	lava.get_active_material(0).set_shader_parameter('low_color', cur_level.waves_low)
	lava.get_active_material(0).set_shader_parameter('high_color', cur_level.waves_high)
	
	lava_b.get_active_material(0).albedo_color = cur_level.waves_bottom
	death_screen.color = cur_level.waves_high
	death_screen.color.a = 0
	
	gate_area = cur_level.get_node('Exit/Gate')
	
	for i in range(cur_level.start_enemies):
		spawn_enemy()
	spawn_timer.start(enemy_spawn_time)

func _ready():
	set_level(cur_level_idx)
	
func death():
	player.audio.stream = death_sound
	player.audio.play()
	dying = true
	
func respawn():
	dying = false
	await get_tree().create_timer(respawn_time).timeout
	death_screen.color.a = 0
	reset()
	
func _process(delta):
	seconds += delta
	if seconds >= 60.0:
		seconds -= 60.0
		minutes += 1
	playtime_label.text = format_playtime()
	if dying:
		death_screen.color.a = move_toward(death_screen.color.a, 1.0, 0.05)
		if death_screen.color.a == 1.0:
			respawn()
	if gate_area.overlaps_body(player) and not changing_level:
		changing_level = true
		gate_entered()

func _on_death_box_body_entered(body):
	if body.name == 'Player':
		print(body.name)
		death()
