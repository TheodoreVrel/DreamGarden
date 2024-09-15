extends CanvasLayer

@onready var console: Control = $Control/ScrollContainer/DebugConsole/RichTextLabel #get_node("root/GameManager/CanvasLayer/Debug/ScrollContainer/DebugConsole")

#func _init():
	#$Control/ScrollContainer.

func _process(delta):
	if Input.is_action_just_pressed("console_key"):
		show_console()

func print(variant, v1 = "", v2 = "", v3 = "", v4 = "", v5 = "", v6 = "", v7 = "", v8 = "", v9 = ""):
	console.text += "\n"
	console.text += str(variant) + str(v1) + str(v2) + str(v3) + str(v4) + str(v5) + str(v6) + str(v7) + str(v8) + str(v9)

func show_console():
	visible = !visible
