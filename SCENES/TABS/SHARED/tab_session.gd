extends TabContainer

signal session_id_changed

var session: Session
var session_id: int

@export var TabSpriteEdit: PackedScene
@export var TabSpriteEditor: PackedScene
@export var TabCellEdit: PackedScene
@export var TabScriptEdit: PackedScene
@export var TabScriptEditCode: PackedScene
@export var TabPaletteEdit: PackedScene
@export var TabSelectEdit: PackedScene

@export var popup: PopupMenu

var base_name: String = ""


func _ready() -> void:
	SessionData.tab_reset_session_ids.connect(reset_session_id)
	set_popup(popup)


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	var e: InputEventMouseButton = event
	
	if not e.pressed:
		return
	
	if e.is_echo():
		return
	
	if e.button_index == MOUSE_BUTTON_RIGHT:
		print("Tab right clicked")


func initialize(p_session: Session) -> void:
	session = p_session
	load_tabs(session.archive)


func reset_session_id() -> void:
	session_id = get_index()
	session_id_changed.emit(session_id)


func load_tabs(archive: BinArchive) -> void:
	for object: BinObject in archive.objects:
		if object is BinSprite:
			add_child(load_sprite(object))
		
		elif object is BinSpriteSelectBlock:
			add_child(load_sprite_list_select(object))
		
		elif object is BinSpriteBlock:
			add_child(load_sprite_list(object))
		
		elif object is BinJPFPlainText:
			add_child(load_jpf_plain_text(object))
		
		elif object is BinScriptable:
			add_child(load_scriptable(object))
		
		elif object is BinScriptableBlock:
			add_child(load_multi_scriptable(object))
			
		#"unsupported":
			#print("Loading unsupported")


#region Editor creation
func get_sprite_editor(object: BinObject) -> SpriteEditor:
	var sprite_editor: SpriteEditor = TabSpriteEditor.instantiate()
	sprite_editor.initialize(session, object)
	return sprite_editor


func get_cell_editor(object: BinScriptable) -> CellEdit:
	var cell_edit: CellEdit = TabCellEdit.instantiate()
	session_id_changed.connect(cell_edit.set_session_id)
	cell_edit.session_id = session_id
	cell_edit.obj_data = object
	return cell_edit


func get_script_editor(object: BinScriptable) -> ScriptEdit:
	var script_edit: ScriptEdit = TabScriptEdit.instantiate()
	session_id_changed.connect(script_edit.set_session_id)
	script_edit.session_id = session_id
	script_edit.obj_data = object
	return script_edit


func get_script_editor_code(object: BinScriptable) -> ScriptEditCode:
	var script_edit_code: ScriptEditCode = TabScriptEditCode.instantiate()
	session_id_changed.connect(script_edit_code.set_session_id)
	script_edit_code.session_id = session_id
	script_edit_code.obj_data = object
	return script_edit_code


func get_palette_editor(object: BinScriptable) -> PaletteEdit:
	var palette_edit: PaletteEdit = TabPaletteEdit.instantiate()
	session_id_changed.connect(palette_edit.set_session_id)
	palette_edit.session_id = session_id
	palette_edit.obj_data = object
	return palette_edit


func get_select_editor(object: BinCursorMask) -> SelectEdit:
	var select_edit: SelectEdit = TabSelectEdit.instantiate()
	session_id_changed.connect(select_edit.set_session_id)
	select_edit.session_id = session_id
	select_edit.obj_data = object
	return select_edit
#endregion


#region Tab control creation
func get_base_tab() -> TabContainer:
	var new_tab: TabContainer = TabContainer.new()
	new_tab.anchor_right = 1
	new_tab.anchor_bottom = 1
	
	return new_tab


func load_sprite(object: BinSpriteBlock) -> TabContainer:
	var new_tab: TabContainer = get_base_tab()
	new_tab.name = "#%s | %s" % [get_child_count(), tr("TAB_TITLE_SPRITE")]
	
	new_tab.add_child(get_sprite_editor(object))
	
	return new_tab


func load_sprite_list_select(object: BinSpriteSelectBlock) -> TabContainer:
	var new_tab: TabContainer = get_base_tab()
	new_tab.name = "#%s | %s" % [get_child_count(), tr("TAB_TITLE_SPRITE_LIST_SELECT")]
	
	new_tab.add_child(get_sprite_editor(object))
	new_tab.add_child(get_select_editor(object.cursor_mask))
	
	return new_tab


func load_sprite_list(object: BinSpriteBlock) -> TabContainer:
	var new_tab: TabContainer = get_base_tab()
	new_tab.name = "#%s | %s" % [get_child_count(), tr("TAB_TITLE_SPRITE_LIST")]
	
	new_tab.add_child(get_sprite_editor(object))
	
	return new_tab


func load_jpf_plain_text(object: BinJPFPlainText) -> TabContainer:
	var new_tab: TabContainer = get_base_tab()
	new_tab.name = "#%s | %s" % [get_child_count(), tr("TAB_TITLE_PLAIN_TEXT")]
	
	new_tab.add_child(get_sprite_editor(object))
	
	return new_tab


func load_scriptable(object: BinScriptable, number: int = -1) -> TabContainer:
	var new_tab: TabContainer = get_base_tab()
	var object_number: int = get_child_count()
	
	if number > -1:
		object_number = number
	
	new_tab.add_child(get_sprite_editor(object))
	new_tab.add_child(get_cell_editor(object))
	
	if object.has_script() and ScriptInstructions.INSTRUCTION_DB.size() > 0:
		new_tab.add_child(get_script_editor(object))
		#new_tab.add_child(get_script_editor_code(object))
	
	if object.has_palettes():
		new_tab.name = "#%s | %s" % [object_number, tr("TAB_TITLE_PLAYER")]
		new_tab.add_child(get_palette_editor(object))
	else:
		new_tab.name = "#%s | %s" % [object_number, tr("TAB_TITLE_OBJECT")]
	
	return new_tab


func load_multi_scriptable(object: BinScriptableBlock) -> TabContainer:
	var new_tab: TabContainer = get_base_tab()
	new_tab.name = "#%s | %s" % [get_child_count(), tr("TAB_TITLE_MULTI_SCRIPTABLE")]
	
	var index: int = 0
	for sub_object in object.scriptables:
		new_tab.add_child(
			load_scriptable(sub_object, index)
		)
		
		index += 1
	
	return new_tab
#endregion
