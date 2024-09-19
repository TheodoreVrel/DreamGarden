extends Trinket



func _ready():
	aoe_sprite = $AoESprite2D
	movable = true

func _process(delta):
	if movable and dragging and Globals.current_mode == Globals.mode.ARRANGE:
		#var mousepos = get_global_mouse_position()
		self.position = get_global_mouse_position()
	
	if Input.is_action_pressed("shift") and mouse_in_zone:
		#holding_key = true
		change_aoe_visibility(aoe_sprite, PlantingZone.zone_interaction_type.RAIN, true)
	elif Input.is_action_just_released("shift"):
		#holding_key = false
		change_aoe_visibility(aoe_sprite, PlantingZone.zone_interaction_type.EXITED, false)

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




func _on_effect_area_2d_area_entered(area):
	plots_affected.append(area.get_parent())
	#all_plots_in_sun_zone.emit(plots_affected)
	for plot in plots_affected:
		if !plot.umbrellas_affecting.has(self):
			plot.umbrellas_affecting.append(self)
	#area.get_parent().sun_change()


func _on_effect_area_2d_area_exited(area):
	
	if area.get_parent() is PlantingZone and area.get_parent().umbrellas_affecting.has(self):
			plots_affected.erase(area.get_parent())
			area.get_parent().zone_interaction(2)
			area.get_parent().umbrellas_affecting.erase(self)
			#print("in the sun is ", area.get_parent().in_the_sun(), " because ", area.get_parent().sun_lamps_affecting)
			#if area.get_parent().sun_lamps_affecting.is_empty():
				#area.get_parent().sun_change()
