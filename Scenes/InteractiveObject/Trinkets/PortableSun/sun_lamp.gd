extends Node2D


var animation_running : bool = false

func _ready():
	animate_slight_nudge()

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

func change_aoe_visibility():
	$AoESprite2D.visible = !$AoESprite2D.visible

func interact_with():
	animate_slight_nudge()
	change_aoe_visibility()
