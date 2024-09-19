extends InteractiveObject
class_name Trinket

var mouse_in_zone : bool = false

var aoe_sprite : Sprite2D
var plots_affected : Array


func _ready():
	movable = true
	#animate_slight_nudge()
	

func _process(delta):
	if movable and dragging and Globals.current_mode == Globals.mode.ARRANGE:
		#var mousepos = get_global_mouse_position()
		self.position = get_global_mouse_position()
	
	if Input.is_action_pressed("shift") and mouse_in_zone:
		#holding_key = true
		change_aoe_visibility(aoe_sprite, PlantingZone.zone_interaction_type.SUN, true)
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


func change_aoe_visibility(sprite: Sprite2D, plot_color_type : zone_interaction_type, vis : bool = !visible, do : bool = true):
	#print(plot_color_type)
	if do:
		sprite.visible = vis
		for plot in plots_affected:
			plot.zone_interaction(plot_color_type)
