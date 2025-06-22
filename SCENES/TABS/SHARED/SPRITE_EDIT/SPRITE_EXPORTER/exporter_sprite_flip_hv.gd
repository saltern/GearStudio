extends CheckButton

enum FlipMode {
	HORIZONTAL,
	VERTICAL,
}

@export var mode: FlipMode


func _toggled(toggled_on: bool) -> void:
	match mode:
		FlipMode.HORIZONTAL:
			SpriteExport.set_sprite_flip_h(toggled_on)
		FlipMode.VERTICAL:
			SpriteExport.set_sprite_flip_v(toggled_on)
