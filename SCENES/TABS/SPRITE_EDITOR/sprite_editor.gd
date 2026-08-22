class_name SpriteEditor extends MarginContainer

signal sprite_changed
signal preview_outdated
signal info_outdated

enum Mode {
	SPRITE_BLOCK,
	SCRIPTABLE,
}

var mode: Mode
var session: Session
var object: BinObject

var scriptable: BinScriptable
var sprite_block: BinSpriteBlock

var this_sprite: BinSprite

@export var control_spr_index: SteppingSpinBox


func _enter_tree() -> void:
	set_sprite(0)


func _ready() -> void:
	control_spr_index.value_changed.connect(control_set_sprite)


func initialize(p_session: Session, p_object: BinObject) -> void:
	session = p_session
	object = p_object
	
	if object is BinScriptable:
		mode = Mode.SCRIPTABLE
		scriptable = object
	else:
		mode = Mode.SPRITE_BLOCK
		sprite_block = object


func notify_info_outdated() -> void:
	info_outdated.emit()


func notify_preview_outdated() -> void:
	preview_outdated.emit()
 

func get_sprite_count() -> int:
	return object.get_sprite_count()


func set_sprite(index: int) -> void:
	this_sprite = object.get_sprite(index)


func object_has_palettes() -> bool:
	return mode == Mode.SCRIPTABLE && scriptable.has_palettes()


func get_palette_count() -> int:
	if object_has_palettes():
		return scriptable.get_palette_count()
	else:
		return 0


func get_current_palette() -> PackedByteArray:
	if mode == Mode.SCRIPTABLE and scriptable.has_palettes():
		return scriptable.get_palette_array(session.palette_index)
	else:
		return this_sprite.palette


func control_set_sprite(index: int) -> void:
	set_sprite(index)
	sprite_changed.emit(index)
	notify_info_outdated()


func control_reindex_sprite() -> void:
	this_sprite.reindex_pixels()
	notify_preview_outdated()


func control_cut_depth() -> void:
	this_sprite.cut_bit_depth()
	notify_info_outdated()
	notify_preview_outdated()


func control_flip_h() -> void:
	this_sprite.flip_h()
	notify_preview_outdated()


func control_flip_v() -> void:
	this_sprite.flip_v()
	notify_preview_outdated()
