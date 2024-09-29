extends SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()
@onready var provider: PaletteProvider = sprite_edit.provider


func _ready() -> void:
	if sprite_edit.obj_data.name != "player":
		get_parent().queue_free()
	
	value_changed.connect(select_palette)
	max_value = sprite_edit.pal_data.palettes.size() - 1


func select_palette(index: int) -> void:
	if sprite_edit.obj_data.name != "player":
		return
		
	provider.palette_load_player(index)
