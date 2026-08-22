extends SteppingSpinBox

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	editor.sprite_changed.connect(update.unbind(1))
	
	max_value = 0xFFFF
	update()


func update() -> void:
	set_value_no_signal(editor.this_sprite.id_hash)
