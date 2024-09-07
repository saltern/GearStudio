extends Node


var pal_selection: Array[bool] = []
var pal_data: Array[Color] = []

var box_data: Array[BoxInfo] = []
var sprite_info: SpriteInfo


func _ready() -> void:
	pal_selection.resize(256)
