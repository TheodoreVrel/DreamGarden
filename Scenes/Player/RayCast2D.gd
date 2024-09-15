extends RayCast2D


signal entered(new_collider)
signal exited(old_collider)
#signal collision_begin(new_collider)
#signal collision_stop(old_collider)
#signal collision_change(old_collider, new_collider)



var old_collider:Object

func _ready():
	pass

func _physics_process(_delta:float) -> void:
	var new_collider:Object = null
	if is_colliding():
		new_collider = get_collider()

	if new_collider == old_collider:
		return

	if old_collider == null:
		#emit_signal("collision_begin", new_collider)
		emit_signal("entered", new_collider)
	elif new_collider == null:
		#emit_signal("collision_stop", old_collider)
		emit_signal("exited", old_collider)
	else:
		#emit_signal("collision_change", old_collider, new_collider)
		emit_signal("exited", old_collider)
		emit_signal("entered", new_collider)

	old_collider = new_collider
