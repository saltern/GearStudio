extends Label

@export var timeline: HSlider

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	script_edit.action_seek_to_frame.connect(update)
	timeline.value_changed.connect(update)


func update(value: int) -> void:
	text = "%d" % [value]
