extends Label

@export var timeline: HSlider


func _ready() -> void:
	timeline.changed.connect(update)
	update()


func update() -> void:
	text = "%d" % timeline.max_value
