extends Label

@export var timeline: HSlider


func _ready() -> void:
	timeline.value_changed.connect(update)


func update(value: int) -> void:
	text = "%d" % [value]
