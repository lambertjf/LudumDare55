extends Node3D

@export var sky : Color = Color(0, 0, 0, 1.0)
@export var sky_hor : Color = Color(0, 0, 0, 1.0)
@export var waves_low : Color = Color(0, 0, 0, 1.0)
@export var waves_high : Color = Color(0, 0, 0, 1.0)
@export var waves_bottom : Color = Color(0, 0, 0, 1.0)

@export var start_enemies = 3
@export var enemy_spawn_time_base = 10.0
@export var time_mod = 0.9
@export var enemy_speed = 2.0
