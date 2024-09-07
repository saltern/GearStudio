extends MarginContainer


func _ready() -> void:
	SessionData.object_state_get(get_parent().name).cell_load(0)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
		
	if not event is InputEventKey:
		return
		
	if not event.pressed or event.echo:
		return
	
	if Input.is_action_just_pressed("undo"):
		SessionData.undo()
	
	elif Input.is_action_just_pressed("redo"):
		SessionData.redo()

	if Input.is_action_just_pressed("ui_copy"):
		if Input.is_key_pressed(KEY_ALT):
			var sprite_info := SessionData.cell_get_this().sprite_info
			
			# duplicate() doesn't work here even with (true) for some reason
			var sprite_info_copy := SpriteInfo.new()
			sprite_info_copy.index = sprite_info.index
			sprite_info_copy.position = sprite_info.position
			sprite_info_copy.unknown = sprite_info.unknown
			
			Clipboard.sprite_info = sprite_info_copy
			
			Status.set_status("Copied Sprite Info for cell #%s." %
				SessionData.cell_get_index())
		
		else:
			if SessionData.box_get_selected_count() == 0:
				Status.set_status("No boxes selected, nothing copied.")
			else:
				Clipboard.box_data.clear()
				
				for box in SessionData.box_get_selected():
					# duplicate() doesn't work here either
					var this_box := SessionData.box_get(box)
					var new_box := BoxInfo.new()
					new_box.rect = this_box.rect
					new_box.type = this_box.type
					new_box.crop_x_offset = this_box.crop_x_offset
					new_box.crop_y_offset = this_box.crop_y_offset
					
					Clipboard.box_data.append(new_box)
				
				Status.set_status("Copied box(es).")

	if Input.is_action_just_pressed("ui_paste"):
		if Input.is_key_pressed(KEY_ALT):
			SessionData.sprite_info_paste()

		elif Input.is_key_pressed(KEY_SHIFT):
			SessionData.box_paste(true)
		
		else:
			SessionData.box_paste(false)
