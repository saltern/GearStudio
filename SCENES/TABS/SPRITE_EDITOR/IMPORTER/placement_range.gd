extends SteppingSpinBox

enum Mode {
	FROM,
	TO,
}

@export var mode: Mode
@export var dialog: SpriteImportDialog


func _ready() -> void:
	GlobalSignals.sprite_importer_on.connect(on_sprite_importer_on)


func _value_changed(new_value: float) -> void:
	match mode:
		Mode.FROM:
			dialog.placement_from = int(new_value)
		Mode.TO:
			dialog.placement_to = int(new_value)


func on_sprite_importer_on(_session: Session, object: BinSpriteBlock) -> void:
	max_value = object.get_sprite_count() - 1
