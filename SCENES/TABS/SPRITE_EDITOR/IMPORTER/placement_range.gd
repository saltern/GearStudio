extends SteppingSpinBox

enum Mode {
	FROM,
	TO,
}

@export var mode: Mode
@export var dialog: SpriteImportDialog


func _ready() -> void:
	dialog.sprite_range_changed.connect(on_sprite_range_changed)


func _value_changed(new_value: float) -> void:
	match mode:
		Mode.FROM:
			dialog.placement_from = int(new_value)
		Mode.TO:
			dialog.placement_to = int(new_value)


func on_sprite_range_changed(block: BinSpriteBlock) -> void:
	max_value = block.get_sprite_count() - 1
