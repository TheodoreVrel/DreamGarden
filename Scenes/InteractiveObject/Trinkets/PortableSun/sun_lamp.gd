extends InteractiveObject


var animation_running : bool = false
var holding_key : bool = false
var mouse_in_zone : bool = false

#var hovered : bool = false
var plots_affected : Array
signal all_plots_in_sun_zone

func _ready():
	movable = true
	#animate_slight_nudge()
	

func _process(delta):
	if movable and dragging and Globals.current_mode == Globals.mode.ARRANGE:
		#var mousepos = get_global_mouse_position()
		self.position = get_global_mouse_position()
	
	if Input.is_action_pressed("shift") and mouse_in_zone:
		#holding_key = true
		change_aoe_visibility(true)
	elif Input.is_action_just_released("shift"):
		#holding_key = false
		change_aoe_visibility(false)

func animate_slight_nudge():
	if !animation_running:
		animation_running = true
		#for frame_num in range($Sprite2D.hframes-1):
			#if $Sprite2D.frame < 3:
				#$Sprite2D.frame += 1
				#await get_tree().create_timer(0.3).timeout
		#$Sprite2D.frame = 0
		$AnimationPlayer.play("jiggle")
		
	animation_running = false

func change_aoe_visibility(vis : bool = !visible, do : bool = true):
	if do:
		$AoESprite2D.visible = vis
		if vis:
			for plot in plots_affected:
				plot.zone_interaction(1)
		else:
			for plot in plots_affected:
				plot.zone_interaction(2)

func interact_with():
	animate_slight_nudge()
	#change_aoe_visibility()


func _on_interaction_area_2d_mouse_entered():
	#change_aoe_visibility(true, holding_key)
	mouse_in_zone = true


func _on_interaction_area_2d_mouse_exited():
	#change_aoe_visibility(false)
	mouse_in_zone = false

func _on_interaction_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		#print(movable,dragging)
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dragging = true
			#print("---", movable,dragging)
		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			dragging = false
			#print("-o--", movable,dragging)
			
	#if event is InputEventKey:
		#print("input key ", event)
		#if event.keycode == KEY_SHIFT and event.pressed:
			#change_aoe_visibility(true)
		#elif event.keycode == KEY_SHIFT and !event.pressed:
			#change_aoe_visibility(false)
			
	#elif event is InputEventScreenTouch:
		#if event.pressed and event.get_index() == 0:
			#self.position = event.get_position()

func _on_effect_area_2d_area_entered(area):
	#var areas : Array
	#print("in the sun: ", area)
	#if area.get_parent() is PlantingZone and area.get_parent() not in plots_affected:
		#areas.append(area.get_parent())
	plots_affected.append(area.get_parent())
	#all_plots_in_sun_zone.emit(plots_affected)
	for plot in plots_affected:
		if !plot.sun_lamps_affecting.has(self):
			plot.sun_lamps_affecting.append(self)
	area.get_parent().entered_the_sun()


func _on_effect_area_2d_area_exited(area):
	if area.get_parent() is PlantingZone and area.get_parent().sun_lamps_affecting.has(self):
		plots_affected.erase(area.get_parent())
		#area.get_parent().zone_interaction(2)
		area.get_parent().sun_lamps_affecting.erase(self)
		#print("in the sun is ", area.get_parent().in_the_sun(), " because ", area.get_parent().sun_lamps_affecting)
		if area.get_parent().sun_lamps_affecting.is_empty():
			area.get_parent().left_the_sun()
			
		#print("____ ", area.get_parent(), " has left the sun lamp area ", self,
		#". Sun lamps affecting it still :",area.get_parent().sun_lamps_affecting)
		#if area.get_parent().flower_in_zone:
			#print("Time left to grow to full : ", area.get_parent().growth_timer.time_left)
