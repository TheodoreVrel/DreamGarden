extends CharacterBody2D

# How fast the player moves in meters per second.
@export var speed = 140
var can_move : bool = true
var can_interact : bool = true

var generic_flower : PackedScene = preload("res://Scenes/Flower/flower.tscn")
#var cast_zone : Node2D

var target_velocity = Vector2.ZERO

signal cast_hit_object(object)
signal cast_exit_object(object)

#signal try_plant
signal player_interact

func _ready():
	pass

func _physics_process(delta):
	if can_move:
		move_player(delta)


func _process(delta):
	if Input.is_action_just_released("left_click") and can_interact:
		interact()
	if Input.is_action_just_released("ui_down"):
		print("bbb")


func move_player(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()


	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.y = direction.y * speed

	
	# Moving the Character
	velocity = target_velocity
	move_and_slide()
	$Pivot.look_at(get_global_mouse_position())


func interact():
	player_interact.emit()

	
	#if zone and flower :
		#var flower_zone = zone.find_child("FlowerSprites")
		#var flower_markers = zone.find_child("Markers")
		#print("r ", zone.rotation)
		#if flower_zone.get_child_count() == 0:
				#
			#for marker in flower_markers.get_children():
				#var new_flower = flower.duplicate()
				#new_flower.position = marker.position * 8
				#if zone.rotation != 0:
					#new_flower.rotation -= zone.rotation
				#flower_zone.add_child(new_flower)
		
		#zone.flower = "tulip"





#old collider stuff
#func _on_ray_cast_2d_collision_begin(new_collider):
	##print(new_collider)
	#pass
#func _on_ray_cast_2d_collision_change(old_collider, new_collider):
	##print(old_collider, " - ", new_collider)
	#pass
#func _on_ray_cast_2d_collision_stop(old_collider):
	##print(old_collider)
	#pass

func _on_ray_cast_2d_entered(new_collider):
	cast_hit_object.emit(new_collider)

func _on_ray_cast_2d_exited(old_collider):
	cast_exit_object.emit(old_collider)
