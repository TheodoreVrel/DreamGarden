extends InteractiveObject
class_name PlantingZone

@onready var collision_polygon : CollisionPolygon2D = get_child(0).find_child("CollisionPolygon2D")
@onready var polygon : Polygon2D = find_child("Polygon2D")
@onready var growth_timer : Timer = find_child("GrowthTimer")
@onready var area : Area2D = find_child("PlantingZone")

#var default_color: Color = Color.BURLYWOOD
var default_color : Color = Color(102, 74, 53) #modify value between 90 and 40
var hover_color: Color = Color.BISQUE
var click_color: Color = Color.GOLD
var sun_color: Color = Color.GOLD
var rain_color: Color = Color.DODGER_BLUE

var hovered: bool = false

#@export_range(1,4) var zone_size : int 
@export var flower_in_zone: Flower
var zone_full: bool = false

var flower_sprite_zone

var normal_growth_multipler: float = 3.5 # = 60 for minutes
var growth_multiplier : float = 1.0
var sun_growth_multiplier: float = 1.0
#var watered_multiplier: float = 1.25

var total_normal_growth_time : float = 10.0
var quarter_growth_break_points : Array
#var last_breakpoint_passed : float
var next_breakpoint_to_pass : float
var growth_time_left: float
var timer_start: bool = false

func is_in_the_sun() -> bool: return !sun_lamps_affecting.is_empty()
func get_current_sun_multiplier() -> float:
	if is_in_the_sun():
		return sun_growth_multiplier
	else: return 1.0


var water_level: float = 0.0 #goes from 0 to 1
var water_needs: int = 1
func get_current_water_multiplier() -> float:
	var result: float = 0.0
	match(water_needs):
		1: 
			result = 1.9*water_level**2 - 0.75*water_level
			if result > 1.1:
				result = 1.1
		2: 
			result = 0.4*water_level**2 + 0.85*water_level
			if result > 1.2:
				result = 1.2
		3: 
			result = 1.5*water_level - 0.05*water_level**2
			if result > 1.35:
				result = 1.35
		_: 	result = 1.0
	return result
var water_full_time: float = 15.0
var water_empty_time: float = 5.0 * 60

var sun_lamps_affecting : Array
var umbrellas_affecting : Array
#var in_the_sun: bool = false


signal growth_end
signal zone_hovered

func _ready():
	#var player = get_tree().current_scene.find_child("Player", true)
	#print (player)
	#if player:
		#player.connect("cast_hit", _on_zone_cast)
		#player.connect("cast_exit", _on_zone_exit)
	if polygon:
		polygon.color = default_color
		adjust_color_value()
	#growth_timer.connect("timeout", _on_growth_timer_timeout)
	area.connect("mouse_entered", on_mouse_entered)
	area.connect("mouse_exited", on_mouse_exited)

func _process(delta):
	#if Input.is_action_just_pressed("ui_down"):
		#if flower_in_zone:
			#print("____ ", self, "Sun lamps affecting this zone :",area.get_parent().sun_lamps_affecting,
			#". Sun and water multiplier: ", sun_adjust_amount, " | ", sun_growth_multiplier, ", ", in_the_sun())
			#print("Time left to grow to next stage : ", growth_timer.time_left, "     ", growth_time_left)
	#if Input.is_action_just_released("ui_up") and flower_in_zone:
		#print("Timer for zone ", self, " set for ", growth_timer.wait_time, " seconds.\nTime left in this cycle: ", 
		#growth_timer.time_left, ". Total growth time: ", total_normal_growth_time,".\nCurrent adjustments:\n - In the sun [", 
		#in_the_sun(),"]\nWaiting for flower to adjust [", should_adjust,"]\nCurrently adjusted for sun [", adjusted_for_sun,
		#"]\nCurrent_sun_adjustment [", sun_adjust_amount, "]\n__________________")
	#if flower_in_zone:
			#print(sun_adjust_amount)
	if Globals.current_mode == Globals.mode.NORMAL:
		if flower_in_zone and timer_start:
			plant_growth(delta)
		if water_level > 0.0 and umbrellas_affecting.is_empty():
			#print("1")
			water_evaporation(delta)
		if water_level < 1.0 and !umbrellas_affecting.is_empty():
			being_watered(delta)
			#print("2")
		#if water_level < 0.001 or water_level > 1.001:
			##print("3")
			#clamp(water_level, 0, 1)


func zone_interaction(interaction: zone_interaction_type):
	match interaction:
		zone_interaction_type.HOVERED:
			polygon.color = hover_color
			hovered = true
		zone_interaction_type.EXITED:
			hovered = false
			polygon.color = default_color
		zone_interaction_type.CLICKED:
			polygon.color = click_color
		zone_interaction_type.SUN:
			polygon.color = sun_color
		zone_interaction_type.RAIN:
			polygon.color = rain_color

func add_flower_to_zone(flower: Flower):
	#print("FFFFFFFFFFFFFFFFFFF planted flower")
	flower.growth_stage = 0
	if !flower_in_zone:
		flower_in_zone = flower.duplicate()
		flower_in_zone.connect("flower_grew", flower_growth)
		add_flower_visuals()
		
	elif !flower_in_zone.is_fusion and flower_in_zone.growth_stage == 0:
		flower_in_zone.generate_fused_flower(flower)
		zone_full = true
	
	growth_info_setup()

	print("-------------- Added flower with growth stage ", flower_in_zone.growth_stage)

func clear_zone():
	flower_in_zone = null
	zone_full = false
	for flower_sprite in flower_sprite_zone.get_children():
		flower_sprite.queue_free()
	flower_sprite_zone = null
	

func add_flower_visuals():
	#Debug.print("attempting to add visuals. Flower is ", flower_in_zone, " with sprite ", flower_in_zone.plant_texture)
	flower_sprite_zone = find_child("FlowerSprites")
	var flower_markers = find_child("Markers")
	#print("r ", rotation)	
	if flower_sprite_zone.get_child_count() == 0:
		for marker in flower_markers.get_children():
			var flower_sprite : Sprite2D = flower_in_zone.get_flower_plant_sprite()
			#new_flower.grow()
			flower_sprite.position = marker.position * 7.5
			#flower_sprite.position.y -= 5
			if rotation != 0:
				#flower_sprite.position.y += 10
				flower_sprite.rotation -= rotation
			flower_sprite_zone.add_child(flower_sprite)

func plant_growth(delta):
	#apply_watered_multiplier()
	growth_time_left -= delta * get_current_sun_multiplier() * get_current_water_multiplier()
	#print(growth_time_left, "  | sun = ", get_current_sun_multiplier(), "  water = ", get_current_water_multiplier(), " ", water_level)
	
	if growth_time_left <= next_breakpoint_to_pass and !quarter_growth_break_points.is_empty():
		quarter_growth_break_points.erase(next_breakpoint_to_pass)
		print(quarter_growth_break_points)
		if !quarter_growth_break_points.is_empty():
			next_breakpoint_to_pass = quarter_growth_break_points[0]
		flower_growth()
	
	if growth_time_left <= 0:
		timer_start = false

func growth_info_setup():
	sun_growth_multiplier = flower_in_zone.info.get("sun_multiplier")
	water_needs = flower_in_zone.info.get("water_needs")
	total_normal_growth_time = flower_in_zone.info.get("growth_time") * normal_growth_multipler
	growth_time_left = total_normal_growth_time
	var quarter: float = total_normal_growth_time/4.0
	quarter_growth_break_points.clear()
	for i in range(4):
		quarter_growth_break_points.append(quarter * (3-i))
	next_breakpoint_to_pass = quarter_growth_break_points[0]
	
	#if is_in_the_sun():
		#sun_change()
	
	timer_start = true
	#quarter_normal_growth_time = total_normal_growth_time / 4
	#growth_timer.wait_time = quarter_normal_growth_time
	#print("__________________ \ngrowth_time = ", growth_time_left,"\nnext breakpoint: ", 
	#quarter_growth_break_points[0], " | ", next_breakpoint_to_pass, "\nsun: ", sun_growth_multiplier, "\ncurrent: ",growth_multiplier)



func flower_growth():
	for flower_sprite in flower_sprite_zone.get_children():
		update_flower_visuals(flower_sprite, flower_in_zone.growth_stage)
	if flower_in_zone.growth_stage == 3:
		print("growth end, ", self)
		growth_end.emit()
	else: flower_in_zone.grow()

func update_flower_visuals(flower_sprite : Sprite2D, frame: int = -5):
	if frame == -5:
		flower_sprite.frame = flower_in_zone.growth_stage
		#print("updating frame")
	else:
		flower_sprite.frame = frame
		#print(frame)
	
	#print(flower_sprite, "is updating?????  ", flower_sprite.frame)


func on_mouse_entered():
	zone_hovered.emit(self)
func on_mouse_exited():
	zone_hovered.emit(null)


func water_evaporation(delta):
	var sun_effect : float = 1.0
	if is_in_the_sun(): sun_effect = 1.2
	#water_level -= (delta / water_empty_time) * sun_effect
	water_level = clampf(water_level - (delta / water_empty_time) * sun_effect, 0.0, 1.0)
	adjust_color_value()

func being_watered(delta):
	water_level = clampf(water_level + (delta / water_full_time), 0.0, 1.0)
	adjust_color_value()

func adjust_color_value(): 
	default_color.v =  0.9 - water_level * 0.5
	if !hovered: polygon.color = default_color
	#print(default_color.v, "   ", default_color)


	#water_level += (delta / water_full_time)
#func sun_change():
	#
	#if is_in_the_sun():
		#growth_multiplier *= sun_growth_multiplier
		##print("& timer ajusted as zone entered : ", sun_adjust_amount)
	#else: growth_multiplier /= sun_growth_multiplier
#func apply_watered_multiplier():
	#growth_multiplier *= get_current_water_multiplier()
	
