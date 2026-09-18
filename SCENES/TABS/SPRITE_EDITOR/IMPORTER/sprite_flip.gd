extends CheckButton

enum Mode {
	FLIP_H,
	FLIP_V,
}

@export var dialog: SpriteImportDialog
@export var mode: Mode


func _toggled(toggled_on: bool) -> void:
	match mode:
		Mode.FLIP_H:
			dialog.set_sprite_flip_h(toggled_on)
		Mode.FLIP_V:
			dialog.set_sprite_flip_v(toggled_on)
