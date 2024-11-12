extends Node


var pal_selection: Array[bool] = []
var pal_data: Array[Color] = []

var box_data: Array[BoxInfo] = []
var sprite_index: int
var sprite_x_offset: int
var sprite_y_offset: int


func _ready() -> void:
	pal_selection.resize(256)
