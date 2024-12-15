class_name SelectEdit extends MarginContainer

signal select_changed

@export var texture_node: TextureRect


var session_id: int
var obj_data: Dictionary
var image: Image
var image_texture: ImageTexture


func _ready() -> void:
	# Prepare texture
	generate_texture()


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
	obj_data["select_width"] = new_sprite.image.get_width()
	obj_data["select_height"] = new_sprite.image.get_height()
	obj_data["select_pixels"] = new_sprite.pixels
	generate_texture()


func export(path: String) -> void:
	var bin_sprite: BinSprite = BinSprite.new_from_data(
		obj_data["select_pixels"],
		image, 8, PackedByteArray([]))
	
	SpriteExport.export_select(bin_sprite, path)
