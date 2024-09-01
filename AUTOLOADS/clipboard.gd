extends Node


var pal_selection: Array[bool] = []
var pal_data: Array[Color] = []


func _ready() -> void:
	pal_selection.resize(256)
