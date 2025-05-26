class_name SelectEdit extends MarginContainer

signal select_changed

@export var texture_node: TextureRect

var session_id: int
var undo_redo: UndoRedo = UndoRedo.new()

var obj_data: Dictionary

var image: Image


func _ready() -> void:
	undo_redo.max_steps = Settings.misc_max_undo
	
	# Prepare texture
	generate_texture()
	
	GlobalSignals.menu_undo.connect(undo)
	GlobalSignals.menu_redo.connect(redo)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	
	if not event is InputEventKey:
		return
	
	if Input.is_action_just_pressed("undo"):
		undo()
	
	if Input.is_action_just_pressed("redo"):
		redo()


func set_session_id(new_id: int) -> void:
	session_id = new_id


# Undo/Redo status shorthand
func status_register_action(action_text: String) -> void:
	undo_redo.add_do_method(Status.set_status.bind(action_text))
	undo_redo.add_undo_method(Status.set_status.bind(tr("ACTION_UNDO").format({
		"action": action_text
	})))


#region Undo/Redo
func undo() -> void:
	if not is_visible_in_tree():
		return
	
	if not undo_redo.has_undo():
		Status.set_status("ACTION_NO_UNDO")
		return
	
	undo_redo.undo()


func redo() -> void:
	if not is_visible_in_tree():
		return
	
	if not undo_redo.has_redo():
		Status.set_status("ACTION_NO_REDO")
		return
	
	undo_redo.redo()
#endregion


func generate_texture() -> void:
	image = Image.create_from_data(
		obj_data["select_width"],
		obj_data["select_height"],
		false, Image.FORMAT_L8,
		obj_data["select_pixels"]
	)
	
	var image_texture = ImageTexture.create_from_image(image)
	texture_node.texture = image_texture
	
	select_changed.emit()


func import(path: String) -> void:
	var new_sprite: BinSprite = SpriteImport.import_file_direct(path)
	
	var action_text: String = tr("ACTION_SELECT_IMPORT")
	
	undo_redo.create_action(action_text)
	
	undo_redo.add_do_method(set_mask_from_image.bind(new_sprite.image))
	undo_redo.add_undo_method(set_mask_from_image.bind(image))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func export(path: String) -> void:
	if path.get_extension().to_lower() != "png":
		path += ".png"
	
	var sprite: BinSprite = BinSprite.new_from_data(
		obj_data["select_pixels"],
		image.get_width(), image.get_height(),
		image, 8, PackedByteArray([]))
	
	SpriteExporter.export_png_direct(path, sprite, SpriteExport.pal_gray)


func set_mask_from_image(from_image: Image) -> void:
	obj_data["select_width"] = from_image.get_width()
	obj_data["select_height"] = from_image.get_height()
	obj_data["select_pixels"] = from_image.get_data()
	generate_texture()
