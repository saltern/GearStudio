extends SteppingSpinBox

@export var limiter_min: SteppingSpinBox
@export var limiter_max: SteppingSpinBox

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	if limiter_min:
		limiter_min.value_changed.connect(on_min_set)
		max_value = editor.sprite_block.get_sprite_count() - 1
	if limiter_max:
		limiter_max.value_changed.connect(on_max_set)
		max_value = 0


func on_min_set(new_min: int) -> void:
	min_value = new_min


func on_max_set(new_max: int) -> void:
	max_value = new_max
