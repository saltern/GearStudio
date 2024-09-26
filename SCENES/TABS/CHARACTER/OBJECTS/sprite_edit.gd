class_name SpriteEdit extends MarginContainer

signal sprites_deleted

signal sprite_updated
signal palette_updated

var undo: UndoRedo = UndoRedo.new()

var obj_data: ObjectData
var pal_data: PaletteData

var sprite_index: int
var this_sprite: BinSprite

var palette_index: int
var this_palette: BinPalette

@export var sprite_bounds: Control

@export var info_dimensions: Label
@export var info_color_depth: Label
@export var info_embedded_pal: Label

var embedded_pal: bool = false

var provider: PaletteProvider


func _enter_tree() -> void:
	obj_data = SessionData.object_data_get(get_parent().name)
	pal_data = SessionData.palette_data_get(get_parent().get_parent().get_index())
	
	provider = PaletteProvider.new()
	provider.sprite_mode = true
	provider.obj_data = obj_data
	provider.pal_data = pal_data
	
	provider.palette_imported.connect(sprite_set)


func _ready() -> void:
	provider.palette_load(0)
	sprite_set(0)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	
	if not event is InputEventKey:
		return
	
	if Input.is_action_just_pressed("undo"):
		provider.undo()
	
	if Input.is_action_just_pressed("redo"):
		provider.redo()


func get_provider() -> PaletteProvider:
	return provider


func palette_get(index: int) -> PackedByteArray:
	return pal_data.palettes[index].palette


#region Sprites
func sprite_get(index: int) -> BinSprite:
	return obj_data.sprites[index]


func sprite_get_count() -> int:
	return obj_data.sprites.size()


func sprite_set(index: int) -> void:
	sprite_index = index
	this_sprite = sprite_get(sprite_index)
	sprite_updated.emit(this_sprite)
	
	# Hardcoding yay
	if obj_data.name == "player":
		pass
	
	else:
		provider.palette_load(sprite_index)


func sprite_delete(from: int, to: int) -> void:
	var how_many: int = to - from + 1
	
	for index in how_many:
		obj_data.sprites.pop_at(from)
	
	SpriteImport.sprite_placement_finished.emit()
#endregion
