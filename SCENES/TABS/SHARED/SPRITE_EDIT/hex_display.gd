extends Label

@export var source: Range

var pal := PackedColorArray()


func _ready() -> void:
	source.value_changed.connect(update)


func update(new_value: int) -> void:
	text = "%X" % new_value
