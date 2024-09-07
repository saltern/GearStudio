extends OptionButton


func _ready() -> void:
	item_selected.connect(on_palette_alpha_mode_changed)


func on_palette_alpha_mode_changed(mode: int) -> void:
	SpriteExport.palette_alpha_mode = mode as SpriteExport.AlphaMode
