extends OptionButton


func _ready() -> void:
	visibility_changed.connect(update)
	item_selected.connect(update.unbind(1))


func update() -> void:
	SpriteExport.set_palette_alpha_mode(selected as SpriteExport.AlphaMode)
