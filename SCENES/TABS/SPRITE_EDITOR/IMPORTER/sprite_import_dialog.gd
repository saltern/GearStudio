class_name SpriteImportDialog extends BasicDialog

signal session_set
signal placement_method_set
signal placement_manual_range_set
signal placement_by_filename_set
signal palette_embed_set
signal palette_half_size_set
signal palette_half_alpha_set
signal palette_reindex_set
signal sprite_flip_h_set
signal sprite_flip_v_set
signal sprite_as_rgb_set
signal sprite_reindex_set
signal sprite_bit_depth_set

enum PlacementMethod {
	APPEND,
	REPLACE,
	INSERT,
}

enum BitDepthMode {
	NO_CHANGE,
	SET_TO_4,
	SET_TO_8,
}

@export var files_browser: FileDialog

var session: Session
var object: BinSpriteBlock

var files: PackedStringArray

var placement_method: PlacementMethod
var placement_manual_range: bool
var placement_by_filename: bool
var placement_position: int
var placement_from: int
var placement_to: int

var palette_embed: bool
var palette_half_size: bool
var palette_half_alpha: bool
var palette_reindex

var sprite_flip_h: bool
var sprite_flip_v: bool
var sprite_as_rgb: bool
var sprite_reindex: bool
var sprite_bit_depth: BitDepthMode


func _enter_tree() -> void:
	visible = false


func _ready() -> void:
	GlobalSignals.sprite_importer_on.connect(open)
	files_browser.files_selected.connect(set_files)


func open(for_session: Session, for_object: BinSpriteBlock) -> void:
	session = for_session
	object = for_object
	session_set.emit(for_session, for_object)
	show()


func set_files(new_files: PackedStringArray) -> void:
	files = new_files


func set_placement_method(method: PlacementMethod) -> void:
	placement_method = method
	placement_method_set.emit(method)


func set_placement_manual_range(enabled: bool) -> void:
	placement_manual_range = enabled
	placement_manual_range_set.emit(enabled)


func set_placement_by_filename(enabled: bool) -> void:
	placement_by_filename = enabled
	placement_by_filename_set.emit(enabled)


func set_palette_enabled(enabled: bool) -> void:
	palette_embed = enabled
	palette_embed_set.emit(enabled)


func set_palette_half_size(enabled: bool) -> void:
	palette_half_size = enabled
	palette_half_size_set.emit(enabled)


func set_palette_half_alpha(enabled: bool) -> void:
	palette_half_alpha = enabled
	palette_half_alpha_set.emit(enabled)


func set_palette_reindex(enabled: bool) -> void:
	palette_reindex = enabled
	palette_reindex_set.emit(enabled)


func set_sprite_flip_h(enabled: bool) -> void:
	sprite_flip_h = enabled
	sprite_flip_h_set.emit(enabled)


func set_sprite_flip_v(enabled: bool) -> void:
	sprite_flip_v = enabled
	sprite_flip_v_set.emit(enabled)


func set_sprite_as_rgb(enabled: bool) -> void:
	sprite_as_rgb = enabled
	sprite_as_rgb_set.emit(enabled)


func set_sprite_reindex(enabled: bool) -> void:
	sprite_reindex = enabled
	sprite_reindex_set.emit(enabled)


func set_sprite_bit_depth(depth_mode: BitDepthMode) -> void: 
	sprite_bit_depth = depth_mode
	sprite_bit_depth_set.emit(depth_mode)
