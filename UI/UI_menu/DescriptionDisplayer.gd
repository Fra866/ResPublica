extends Control

onready var label = $Background/InnerBackground/Text


func set_text(s: String):
	label.text = s
