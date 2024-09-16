extends InteractiveObject
class_name PlantingZone

@onready var collision_polygon : CollisionPolygon2D = get_child(0).find_child("CollisionPolygon2D")
@onready var polygon : Polygon2D = find_child("Polygon2D")
@onready var growth_timer : Timer = find_child("GrowthTimer")
@onready var area : Area2D = find_child("PlantingZone")

var default_color : Color = Color.CORNFLOWER_BLUE
var hover_color : Color = Color.BISQUE
var click_color : Color = Color.GOLD


@export_range(1,4) var zone_size : int 
var flower_in_zone: Flower
var zone_full : bool = false

var flower_sprite_zone

var growth_multipler: float = 1.5

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
	
	
	handle_flower_growth_timer()
	print("-------------- Added flower with growth stage ", flower_in_zone.growth_stage)

func clear_zone():
	flower_in_zone = null
	zone_full = false
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

func handle_flower_growth_timer():
	if !growth_timer.is_stopped():
		growth_timer.stop()
	growth_timer.wait_time = flower_in_zone.info.get("growth_time")/4.0 * growth_multipler
	growth_timer.one_shot = true
	flower_growth()

func flower_growth():
	for flower_sprite in flower_sprite_zone.get_children():
		update_flower_visuals(flower_sprite, flower_in_zone.growth_stage)
	if flower_in_zone.growth_stage < 3:
		growth_timer.start()
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
