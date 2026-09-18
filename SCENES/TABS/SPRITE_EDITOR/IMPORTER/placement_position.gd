extends SteppingSpinBox

@export var dialog: SpriteImportDialog


func _ready() -> void:
	GlobalSignals.sprite_importer_on.connect(on_sprite_importer_on)


func _value_changed(new_value: float) -> void:
	dialog.placement_position = int(new_value)


func on_sprite_importer_on(_session: Session, object: BinSpriteBlock) -> void:
	max_value = object.get_sprite_count() - 1
