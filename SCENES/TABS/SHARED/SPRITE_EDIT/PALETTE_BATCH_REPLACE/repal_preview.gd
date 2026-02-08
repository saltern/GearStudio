extends TextureRect

@export var sprite_index: SteppingSpinBox
@export var palette_index: SteppingSpinBox
@export var invalid_file: Label	

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	pass


func update_preview() -> void:
	if sprite_edit.obj_data != SpriteImport.obj_data:
		return
	
	var sprite: BinSprite = SpriteImport.preview_sprite
	
	if sprite == null:
		texture = null
		invalid_file.show()
		invalid_file.text = tr("SPRITE_EDIT_IMPORT_PREVIEW_INVALID").format({
			"file": SpriteImport.get_preview_sprite_path()
		})
	else:
		invalid_file.hide()
		texture = sprite.texture
		
		# Is correct, double checked
		material.set_shader_parameter("reindex",
			sprite.bit_depth == 8 or sprite_edit.obj_data.has("palettes"))
		
		if sprite_edit.obj_data.has("palettes"):
			var pal_index: int = SpriteImport.preview_palette_index
			
			material.set_shader_parameter(
				"palette", sprite_edit.obj_data["palettes"][pal_index].palette)
				
		else:
			material.set_shader_parameter("palette", sprite.palette)
