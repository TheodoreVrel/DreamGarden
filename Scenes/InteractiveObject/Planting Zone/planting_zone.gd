extends InteractiveObject
class_name PlantingZone

@onready var collision_polygon : CollisionPolygon2D = get_child(0).find_child("CollisionPolygon2D")
@onready var polygon : Polygon2D = find_child("Polygon2D")
@onready var growth_timer : Timer = find_child("GrowthTimer")
@onready var area : Area2D = find_child("PlantingZone")

var default_color: Color = Color.CORNFLOWER_BLUE
var hover_color: Color = Color.BISQUE
var click_color: Color = Color.GOLD


#@export_range(1,4) var zone_size : int 
@export var flower_in_zone: Flower
var zone_full: bool = false

var flower_sprite_zone

var normal_growth_multipler: float = 10
var sun_growth_multiplier: float = 1.0
var watered_multiplier: float = 1.25

var total_normal_growth_time : float = 0.0
var quarter_normal_growth_time : float = 0.0
var growth_time_left: float
#var adjusted_quarter_growth_time : float

var should_adjust : bool = false
var sun_adjust_amount : float = 1.0 # this is always equal to 1, sun_growth_multiplier or 1/sun_growth_multiplier
var adjusted_for_sun : bool = false
#var adjustment : float #equal to sun_adjust_amount * water_adjust_amount


var sun_lamps_affecting : Array
#var in_the_sun: bool = false
func in_the_sun() -> bool: return !sun_lamps_affecting.is_empty()
var water_level: int = 0
var water_needs: int = 1

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
	growth_timer.connect("timeout", _on_growth_timer_timeout)
	
	area.connect("mouse_entered", on_mouse_entered)
	area.connect("mouse_exited", on_mouse_exited)

func _process(delta):
	if Input.is_action_just_pressed("ui_down"):
		if flower_in_zone:
			print("____ ", self, "Sun lamps affecting this zone :",area.get_parent().sun_lamps_affecting,
			". Sun and water multiplier: ", sun_adjust_amount, " | ", sun_growth_multiplier, ", ", in_the_sun())
			print("Time left to grow to next stage : ", growth_timer.time_left, "     ", growth_time_left)
	if Input.is_action_just_released("ui_up") and flower_in_zone:
		print("Timer for zone ", self, " set for ", growth_timer.wait_time, " seconds.\nTime left in this cycle: ", 
		growth_timer.time_left, ". Total growth time: ", total_normal_growth_time,".\nCurrent adjustments:\n - In the sun [", 
		in_the_sun(),"]\nWaiting for flower to adjust [", should_adjust,"]\nCurrently adjusted for sun [", adjusted_for_sun,
		"]\nCurrent_sun_adjustment [", sun_adjust_amount, "]\n__________________")
	#if flower_in_zone:
			#print(sun_adjust_amount)


func zone_interaction(interaction: zone_interaction_type):
	match interaction:
		zone_interaction_type.HOVERED:
			polygon.color = hover_color
		zone_interaction_type.EXITED:
			#print("exited")
			polygon.color = default_color
		zone_interaction_type.CLICKED:
			polygon.color = click_color


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
	handle_flower_growth_timer()
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

func growth_info_setup():
	sun_growth_multiplier = flower_in_zone.info.get("sun_multiplier")
	water_needs = flower_in_zone.info.get("water_needs")
	total_normal_growth_time = flower_in_zone.info.get("growth_time") * normal_growth_multipler
	quarter_normal_growth_time = total_normal_growth_time / 4
	growth_timer.wait_time = quarter_normal_growth_time
	print("__________________")
	if should_adjust:
		print("# Adjusting when planted because in sun | ", growth_timer.wait_time)
		adjust_timer(false)
		print("# Adjusted when planted because in sun | ", growth_timer.wait_time)
	else:
		print("# Not adjusting when planted because out of sun | ", growth_timer.wait_time)

func handle_flower_growth_timer():
	if !growth_timer.is_stopped():
		growth_timer.stop()
	
	growth_timer.one_shot = true
	flower_growth()

func flower_growth():
	for flower_sprite in flower_sprite_zone.get_children():
		update_flower_visuals(flower_sprite, flower_in_zone.growth_stage)
	if flower_in_zone.growth_stage < 3:
		growth_timer.start(get_adjusted_time_left())
		#print("timer started")
	else:
		print("growth end, ", self)
		growth_end.emit()

func _on_growth_timer_timeout():
	#print("timer done ", flower_in_zone.growth_stage)
	flower_in_zone.grow()

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



#func timer_adjust_for_rate(rate : float, remove_adjustment : bool = false):
	##call once when entering the state
	##if !growth_timer.is_stopped() and growth_timer.time_left >= 0:
		##var adjusted_rate : float
		##if remove_adjustment: adjusted_rate = 1/rate
		##else: adjusted_rate = rate
		##
		##growth_time_left = growth_timer.time_left
		##adjustment = rate
		##flower_growth()
		##print("timer ajusted while flower is growing : ", growth_timer.time_left)
	##else:
		#growth_time_left = growth_timer.time_left
		##adjust_sun = true
		#
		#if remove_adjustment:
			#sun_adjustment = 1/sun_growth_multiplier
		#else:
			#sun_adjustment = sun_growth_multiplier
			#
			#
		#if flower_in_zone:
			#flower_growth()
		##growth_timer.wait_time *= rate
		#
#
#func timer_adjust_for_sun(entered_sunlight : bool = true):
	##call once when entering or leaving the sun
	#timer_adjust_for_rate(sun_growth_multiplier, !entered_sunlight)
	#pass

func entered_the_sun():
	if !flower_in_zone:
		should_adjust = true
		print("& Should adjust for sun later")
		return
	if in_the_sun():
		adjust_timer(!growth_timer.is_stopped())
		print("& timer ajusted as zone entered : ", sun_adjust_amount)
	print("& ", self)
func left_the_sun():
	if !flower_in_zone:
		should_adjust = false
		reset_ajustments()
		print("& Shouldn't adjust for sun later")
		return
	if !in_the_sun():
		adjust_timer(!growth_timer.is_stopped())
		#adjust_sun = false
		print("& timer ajusted as zone left : ", sun_adjust_amount)
	print("& ", self)

func adjust_timer(while_counting: bool):
	if while_counting:
		growth_timer.start(get_adjusted_time_left())
	else:
		growth_timer.wait_time = get_adjusted_time_left()
	print("* Adjusted for sun. While counting down? ", while_counting)
	print("* ", self)
	
func reset_ajustments():
	should_adjust = false
	sun_adjust_amount = 1.0
	adjusted_for_sun = false
	#adjustment = 1.0

func get_adjusted_time_left() -> float: 
	calculate_time_left(in_the_sun())
	return growth_time_left

#func get_sun_multiplier(reverted: bool = false):
	#if !reverted:
		#return sun_growth_multiplier
	#else: return 1/sun_growth_multiplier
func calculate_time_left(in_sun):
	if growth_timer.is_stopped():
		growth_time_left = growth_timer.wait_time
	else:
		growth_time_left = growth_timer.time_left
	adjust_sun_multiplier(in_sun)
	print("@ Calculating time left: ", growth_time_left)
	growth_time_left /= sun_adjust_amount
	print("@ Calculating time left: ", growth_time_left)
	print("@ ", self)
	

func adjust_sun_multiplier(adjust_to_sunny : bool):
	adjust_multiplier(sun_adjust_amount, adjusted_for_sun, adjust_to_sunny, sun_growth_multiplier)
	print("§ Adjusting sun multiplier: ", sun_adjust_amount, " | ", sun_growth_multiplier)
	print("§ ", adjusted_for_sun, adjust_to_sunny)
	print("§ ", self)

func adjust_multiplier(multiplier: float, multiplier_adjusted: bool, adjust_for_thing: bool, adjustment_baseline: float):
	print("¤ Multiplier ", multiplier, " is adjusted: ", multiplier_adjusted, " and must be adjusted: ", adjust_for_thing, " so using ", adjustment_baseline, " to adjust.")
	if multiplier_adjusted == adjust_for_thing:
		multiplier = 1.0
		pass
	elif multiplier_adjusted == false and adjust_for_thing == true:
		multiplier = adjustment_baseline
		
		pass
	elif multiplier_adjusted == true and adjust_for_thing == false:
		multiplier = 1/adjustment_baseline
		pass
	multiplier_adjusted = adjust_for_thing
	print("¤ Multiplier is now ", multiplier, "; adjusted : ", multiplier_adjusted)
	sun_adjust_amount = multiplier
	adjusted_for_sun = multiplier_adjusted
	pass
