extends SpinBox

@export var delete_from: SpinBox
@export var delete_to: SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	delete_from.value_changed.connect(update_min_value)
	delete_to.value_changed.connect(update_max_value)
	
	min_value = 0
	max_value = 0


func update_min_value(new_min_value: int) -> void:
	min_value = new_min_value


func update_max_value(new_max_value: int) -> void:
	max_value = new_max_value
