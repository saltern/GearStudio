extends TabContainer

var session_id: int

@export var TabSpriteEdit: PackedScene
@export var TabCellEdit: PackedScene
@export var TabPaletteEdit: PackedScene
@export var TabSelectEdit: PackedScene

var base_name: String = ""


func load_tabs(data: Dictionary) -> void:
	for object in data["data"].size():
		var this_object: Dictionary = data["data"][object]
		
		match this_object["type"]:
			"sprite":
				#print("Loading sprite")
				add_child(load_sprite(this_object))
			
			"sprite_list_select":
				#print("Loading sprite_list_select")
				add_child(load_sprite_list_select(this_object))
			
			"sprite_list", "sprite_list_file":
				#print("Loading sprite_list")
				add_child(load_sprite_list(this_object))
			
			"jpf_plain_text":
				#print("Loading jpf_plain_text")
				add_child(load_jpf_plain_text(this_object))
			
			"scriptable":
				#print("Loading scriptable")
				add_child(load_scriptable(this_object))
			
			"multi_scriptable":
				#print("Loading multi_scriptable")
				add_child(load_multi_scriptable(this_object))
			
			#"unsupported":
				#print("Loading unsupported")


func get_base_tab() -> TabContainer:
	var new_tab: TabContainer = TabContainer.new()
	new_tab.anchor_right = 1
	new_tab.anchor_bottom = 1
	
	return new_tab


func get_sprite_editor(object: Dictionary) -> SpriteEdit:
	var sprite_edit: SpriteEdit = TabSpriteEdit.instantiate()
	sprite_edit.session_id = session_id
	sprite_edit.obj_data = object
	return sprite_edit


func get_cell_editor(object: Dictionary) -> CellEdit:
	var cell_edit: CellEdit = TabCellEdit.instantiate()
	cell_edit.session_id = session_id
	cell_edit.obj_data = object
	return cell_edit


func get_palette_editor(object: Dictionary) -> PaletteEdit:
	var palette_edit: PaletteEdit = TabPaletteEdit.instantiate()
	palette_edit.session_id = session_id
	palette_edit.obj_data = object
	return palette_edit


func get_select_editor(object: Dictionary) -> SelectEdit:
	var select_edit: SelectEdit = TabSelectEdit.instantiate()
	select_edit.session_id = session_id
	select_edit.obj_data = object
	return select_edit


func load_sprite(object: Dictionary) -> TabContainer:
	var new_tab: TabContainer = get_base_tab()
	new_tab.name = "#%s | Sprite" % get_child_count()
	
	new_tab.add_child(get_sprite_editor(object))
	
	return new_tab


func load_sprite_list_select(object: Dictionary) -> TabContainer:
	var new_tab: TabContainer = get_base_tab()
	new_tab.name = "#%s | Sprites + Cursor Mask" % get_child_count()
	
	new_tab.add_child(get_sprite_editor(object))
	new_tab.add_child(get_select_editor(object))
	
	return new_tab


func load_sprite_list(object: Dictionary) -> TabContainer:
	var new_tab: TabContainer = get_base_tab()
	new_tab.name = "#%s | Sprites" % get_child_count()
	
	new_tab.add_child(get_sprite_editor(object))
	
	return new_tab


func load_jpf_plain_text(object: Dictionary) -> TabContainer:
	var new_tab: TabContainer = get_base_tab()
	new_tab.name = "#%s | Plain Text" % get_child_count()
	
	new_tab.add_child(get_sprite_editor(object))
	
	return new_tab


func load_scriptable(object: Dictionary, number: int = -1) -> TabContainer:
	var new_tab: TabContainer = get_base_tab()
	var object_number: int = get_child_count()
	
	if number > -1:
		object_number = number
	
	new_tab.add_child(get_sprite_editor(object))
	new_tab.add_child(get_cell_editor(object))
	
	if object.has("palettes"):
		new_tab.name = "#%s | %s" % [object_number, tr("TAB_SCRIPTABLE_NAME_PLAYER")]
		new_tab.add_child(get_palette_editor(object))
	else:
		new_tab.name = "#%s | %s" % [object_number, tr("TAB_SCRIPTABLE_NAME_OBJECT")]
	
	return new_tab


func load_multi_scriptable(object: Dictionary) -> TabContainer:
	var new_tab: TabContainer = get_base_tab()
	new_tab.name = "#%s | Effects" % get_child_count()
	
	for sub_object in object["data"]:
		new_tab.add_child(
			load_scriptable(object["data"][sub_object], sub_object)
		)
	
	return new_tab
