extends CheckButton


func _ready() -> void:
	toggled.connect(on_reindex_toggled)


func on_reindex_toggled(enabled: bool) -> void:
	SpriteExport.sprite_reindex = enabled
