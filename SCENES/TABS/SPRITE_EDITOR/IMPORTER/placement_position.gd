extends SteppingSpinBox

@export var dialog: SpriteImportDialog


func _ready() -> void:
	dialog.sprite_range_changed.connect(on_sprite_range_changed)


func _value_changed(new_value: float) -> void:
	dialog.placement_position = int(new_value)


func on_sprite_range_changed(block: BinSpriteBlock) -> void:
	max_value = block.get_sprite_count() - 1
