extends Label


func _ready() -> void:
	SpriteImport.placement_method_set.connect(update)
	SpriteImport.insert_position_set.connect(update)
	SpriteImport.files_selected.connect(update)


func update() -> void:
	var obj_state: ObjectEditState = SessionData.object_state_get(
		get_owner().get_parent().name)
	
	var sprite_count: int = obj_state.sprite_get_count()
	var import_count: int = SpriteImport.import_list.size()
	
	match SpriteImport.placement_method:
		SpriteImport.PlaceMode.APPEND:
			text = "Will not replace sprites. New sprite count: %s" % \
			[sprite_count + import_count]
			
		SpriteImport.PlaceMode.REPLACE:
			var replace_count: int = min(
				sprite_count - SpriteImport.insert_position, import_count)
			
			if replace_count == 0:
				text = "Will not replace sprites. New sprite count: %s" % \
				[sprite_count + import_count]
			
			else:
				text = "Will REPLACE %s sprite(s)! New sprite count: %s" % \
				[replace_count, sprite_count + import_count - replace_count]
			
		SpriteImport.PlaceMode.INSERT:
			var displace_count: int = sprite_count - SpriteImport.insert_position
			
			if displace_count == 0:
				text = "Will not displace sprites. New sprite count: %s" % \
				[sprite_count + import_count]
			
			else:
				text = "Will DISPLACE %s sprite(s)! New sprite count: %s" % \
				[displace_count, sprite_count + import_count]
