extends SteppingSpinBox

enum Mode {
	FROM,
	TO,
}

@export var batch_tool: BatchProcessingTool
@export var mode: Mode
@export var limiter_min: SteppingSpinBox
@export var limiter_max: SteppingSpinBox

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	if limiter_min:
		limiter_min.value_changed.connect(on_min_set)
		editor.sprite_range_changed.connect(set_real_maximum)
		set_real_maximum()
	if limiter_max:
		limiter_max.value_changed.connect(on_max_set)
		max_value = 0


func _value_changed(new_value: float) -> void:
	match mode:
		Mode.FROM:
			batch_tool.set_from(new_value)
		Mode.TO:
			batch_tool.set_to(new_value)


func on_min_set(new_min: int) -> void:
	min_value = new_min


func on_max_set(new_max: int) -> void:
	max_value = new_max


func set_real_maximum() -> void:
	max_value = editor.get_sprite_count() - 1
