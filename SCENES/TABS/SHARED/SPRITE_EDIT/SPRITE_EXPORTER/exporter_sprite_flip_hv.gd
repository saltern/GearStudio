extends CheckButton

enum FlipMode {
	HORIZONTAL,
	VERTICAL,
}

@export var mode: FlipMode


func _ready() -> void:
	visibility_changed.connect(update)


func _toggled(toggled_on: bool) -> void:
	match mode:
		FlipMode.HORIZONTAL:
			SpriteExport.set_sprite_flip_h(toggled_on)
		FlipMode.VERTICAL:
			SpriteExport.set_sprite_flip_v(toggled_on)


func update() -> void:
	if visible:
		_toggled(button_pressed)
