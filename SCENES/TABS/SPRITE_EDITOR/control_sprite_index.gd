# Sprite selector for the SpriteEditor.
extends SteppingSpinBox

@export var limiter_min: SteppingSpinBox
@export var limiter_max: SteppingSpinBox

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	editor.sprite_range_changed.connect(update_max)
	editor.sprite_forced.connect(force_update)
	update_max()
	
	if limiter_min:
		limiter_min.value_changed.connect(min_set)
	if limiter_max:
		limiter_max.value_changed.connect(max_set)


func update_max() -> void:
	max_value = editor.get_sprite_count() - 1


func _value_changed(new_value: float) -> void:
	editor.set_sprite(new_value)


func force_update(new_value: int) -> void:
	set_value_no_signal(new_value)


func min_set(new_value: int) -> void:
	min_value = new_value


func max_set(new_value: int) -> void:
	max_value = new_value
