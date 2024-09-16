extends Control

@onready var label = $Label

func update_tooltip(flower_info : Dictionary):
	label.text = "[color=black]"
	for info in flower_info:
		label.text += str(info) + " : " + str(flower_info.get(info)) + "\n"
	label.text += "[/color]"

func show_tooltip(show_tooltip : bool):
	visible = show_tooltip
