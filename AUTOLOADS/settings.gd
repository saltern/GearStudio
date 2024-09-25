extends Node

@warning_ignore("unused_signal")
signal display_window
@warning_ignore("unused_signal")
signal draw_origin_changed
@warning_ignore("unused_signal")
signal onion_color_changed
signal sprite_bounds_color_changed

const FILENAME: String = "/gearstudio.ini"

const CFG_SECTION_CELLS: String = "cells"
const CFG_CELL_ONION: String = "onion_color"
const CFG_CELL_ORIGIN: String = "draw_origin"

const CFG_SECTION_BOXES: String = "boxes"
const CFG_BOX_THICKNESS: String = "thickness"
const CFG_BOX_COLOR_UNK: String = "color_unknown"
const CFG_BOX_COLOR_HIT: String = "color_hitbox"
const CFG_BOX_COLOR_HURT: String = "color_hurtbox"
const CFG_BOX_COLOR_CROP_B: String = "color_region_b"
const CFG_BOX_COLOR_CROP_F: String = "color_region_f"
const CFG_BOX_COLOR_COLL_EXT: String = "color_collision"
const CFG_BOX_COLOR_SPAWN: String = "color_spawn"

const CFG_SECTION_SPRITES: String = "sprites"
const CFG_SPRITE_COLOR_BOUNDS: String = "color_bounds"
const CFG_SPRITE_REINDEX: String = "reindex"

const CFG_SECTION_PALETTES: String = "palettes"
const CFG_PALETTE_ALPHA: String = "alpha_double"

const CFG_SECTION_MISC: String = "misc"
const CFG_MISC_MAX_UNDO: String = "max_undo"
const CFG_MISC_REOPEN: String = "allow_reopen"

enum BoxType {
	UNKNOWN,			# ...
	HITBOX,				# 1
	HURTBOX,			# 2
	REGION_B,			# 3
	COLLISION_EXTEND,	# 4
	SPAWN,				# 5
	REGION_F,			# 6
}

var cell_draw_origin: bool = true
var cell_onion_skin: Color = Color8(255, 0, 0, 0xA0)

var box_thickness: int = 2
var box_colors: Array[Color] = [
	Color.WHITE,
	Color.RED,
	Color.GREEN,
	Color.CORNFLOWER_BLUE,
	Color.PURPLE,
	Color.GOLD,
	Color.CYAN,
]

var sprite_color_bounds: Color = Color.BLACK:
	set(value):
		sprite_color_bounds = value
		sprite_bounds_color_changed.emit()

var sprite_reindex: bool = true

var palette_alpha_double: bool = true

var misc_max_undo: int = 0
var misc_allow_reopen: bool = true

var config: ConfigFile = ConfigFile.new()

@onready var path: String = OS.get_executable_path().get_base_dir()


func _ready() -> void:
	load_config()


func load_config() -> bool:
	if config.load(path + FILENAME) != OK:
		return false
	
	cell_draw_origin = config.get_value(
		CFG_SECTION_CELLS, CFG_CELL_ORIGIN, true)
	
	cell_onion_skin = config.get_value(
		CFG_SECTION_CELLS, CFG_CELL_ONION, Color(1.0, 0.0, 0.0, 0.625))
	
	box_thickness = config.get_value(CFG_SECTION_BOXES, CFG_BOX_THICKNESS, 2)
	box_colors = [
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_UNK, box_colors[0]),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_HIT, box_colors[1]),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_HURT, box_colors[2]),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_CROP_B, box_colors[3]),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_COLL_EXT, box_colors[4]),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_SPAWN, box_colors[5]),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_CROP_F, box_colors[6]),
	]
	
	sprite_color_bounds = config.get_value(
		CFG_SECTION_SPRITES, CFG_SPRITE_COLOR_BOUNDS, Color.BLACK)
		
	sprite_reindex = config.get_value(
		CFG_SECTION_SPRITES, CFG_SPRITE_REINDEX, true)
	
	palette_alpha_double = config.get_value(
		CFG_SECTION_PALETTES, CFG_PALETTE_ALPHA, true)
	
	misc_max_undo = config.get_value(
		CFG_SECTION_MISC, CFG_MISC_MAX_UNDO, 0)
		
	misc_allow_reopen = config.get_value(
		CFG_SECTION_MISC, CFG_MISC_REOPEN, true)
	
	return true


func save_config() -> bool:
	config.set_value(
		CFG_SECTION_CELLS, CFG_CELL_ORIGIN, cell_draw_origin)
	config.set_value(
		CFG_SECTION_CELLS, CFG_CELL_ONION, cell_onion_skin)
	
	config.set_value(
		CFG_SECTION_BOXES, CFG_BOX_THICKNESS, box_thickness)
	config.set_value(
		CFG_SECTION_BOXES, CFG_BOX_COLOR_UNK, box_colors[BoxType.UNKNOWN])
	config.set_value(
		CFG_SECTION_BOXES, CFG_BOX_COLOR_HIT, box_colors[BoxType.HITBOX])
	config.set_value(
		CFG_SECTION_BOXES, CFG_BOX_COLOR_HURT, box_colors[BoxType.HURTBOX])
	config.set_value(
		CFG_SECTION_BOXES, CFG_BOX_COLOR_CROP_B, box_colors[BoxType.REGION_B])
	config.set_value(
		CFG_SECTION_BOXES, CFG_BOX_COLOR_COLL_EXT, box_colors[BoxType.COLLISION_EXTEND])
	config.set_value(
		CFG_SECTION_BOXES, CFG_BOX_COLOR_SPAWN, box_colors[BoxType.SPAWN])
	config.set_value(
		CFG_SECTION_BOXES, CFG_BOX_COLOR_CROP_F, box_colors[BoxType.REGION_F])
	
	config.set_value(
		CFG_SECTION_SPRITES, CFG_SPRITE_COLOR_BOUNDS, sprite_color_bounds)
	config.set_value(
		CFG_SECTION_SPRITES, CFG_SPRITE_REINDEX, sprite_reindex)
	
	config.set_value(
		CFG_SECTION_PALETTES, CFG_PALETTE_ALPHA, palette_alpha_double)
	
	config.set_value(CFG_SECTION_MISC, CFG_MISC_MAX_UNDO, misc_max_undo)
	config.set_value(CFG_SECTION_MISC, CFG_MISC_REOPEN, misc_allow_reopen)
	
	if config.save(path + FILENAME) != OK:
		return false
		
	return true
