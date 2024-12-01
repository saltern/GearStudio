extends TextureRect

const ERR_STRING: String = \
	"The file was not found or is not a valid sprite.\n(%s)"

@export var invalid_file: Label

var gray_pal: PackedInt32Array

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	for index in 256:
		gray_pal.append_array([index, index, index, 0xFF])
	
	SpriteImport.preview_generated.connect(update_preview)
	SpriteImport.preview_palette_set.connect(update_preview)


func update_preview() -> void:
	if sprite_edit.obj_data != SpriteImport.obj_data:
		return
	
	var sprite: BinSprite = SpriteImport.preview_sprite
	
	if sprite == null:
		texture = null
		invalid_file.show()
		invalid_file.text = ERR_STRING % SpriteImport.get_preview_sprite_path()
	else:
		invalid_file.hide()
		texture = sprite.texture
		
		# Is correct, double checked
		material.set_shader_parameter("reindex",
			sprite.bit_depth == 8 or SpriteImport.obj_data.name == "player")
		
		if sprite_edit.obj_data.has("palettes"):
			var pal_index: int = SpriteImport.preview_palette_index
			
			material.set_shader_parameter(
				"palette", sprite_edit.obj_data["palettes"][pal_index].palette)
				
		else:
			material.set_shader_parameter("palette", sprite.palette)
