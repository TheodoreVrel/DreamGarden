extends Node

enum mode{NORMAL, ARRANGE}
@export var current_mode : mode = mode.NORMAL

enum scene_state{GAME, PAUSE, OPENING}
var current_scene_state : scene_state = scene_state.GAME


func _process(delta):
	if Input.is_action_just_pressed("tab") and current_mode == mode.NORMAL:
		current_mode = mode.ARRANGE
		print(current_mode)
	elif Input.is_action_just_pressed("tab") and current_mode == mode.ARRANGE:
		current_mode = mode.NORMAL
		print(current_mode)
