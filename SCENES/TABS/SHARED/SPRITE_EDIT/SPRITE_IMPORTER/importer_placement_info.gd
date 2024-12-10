extends Label

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	SpriteImport.placement_method_set.connect(update)
	SpriteImport.insert_position_set.connect(update)
	SpriteImport.files_selected.connect(update)
	SpriteImport.sprite_placement_finished.connect(update)
	visibility_changed.connect(update)


func update() -> void:
	if not visible:
		return
	
	var sprite_count: int = sprite_edit.sprite_get_count()
	var import_count: int = SpriteImport.import_list.size()
	
	match SpriteImport.placement_method:
		SpriteImport.PlaceMode.APPEND:
			text = tr("SPRITE_EDIT_IMPORT_PLACEMENT_NO_REPLACE").format({
				"total": sprite_count + import_count
			})
			
		SpriteImport.PlaceMode.REPLACE:
			var replace_count: int = min(
				sprite_count - SpriteImport.insert_position, import_count)
			
			if replace_count == 0:
				text = tr("SPRITE_EDIT_IMPORT_PLACEMENT_NO_REPLACE").format({
					"total": sprite_count + import_count
				})
			
			else:
				text = tr("SPRITE_EDIT_IMPORT_PLACEMENT_WILL_REPLACE").format({
					"replace": replace_count,
					"total": sprite_count + import_count - replace_count
				})
			
		SpriteImport.PlaceMode.INSERT:
			var displace_count: int = sprite_count - SpriteImport.insert_position
			
			if displace_count == 0:
				text = tr("SPRITE_EDIT_IMPORT_PLACEMENT_NO_DISPLACE").format({
					"total": sprite_count + import_count
				})
			
			else:
				text = tr("SPRITE_EDIT_IMPORT_PLACEMENT_WILL_DISPLACE").format({
					"displace": displace_count,
					"total": sprite_count + import_count
				})
