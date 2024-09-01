extends Node

signal display_window

const FILENAME: String = "/gearstudio.ini"

const CFG_SECTION_CELLS: String = "cells"
const CFG_CELL_ONION: String = "onion_color"

const CFG_SECTION_BOXES: String = "boxes"
const CFG_BOX_THICKNESS: String = "thickness"
const CFG_BOX_COLOR_UNK: String = "color_unknown"
const CFG_BOX_COLOR_HIT: String = "color_hitbox"
const CFG_BOX_COLOR_HURT: String = "color_hurtbox"
const CFG_BOX_COLOR_CROP: String = "color_region"
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
	UNKNOWN,
	HITBOX,
	HURTBOX,
	REGION,
	UNKNOWN_2,
	SPAWN,
}

var cell_onion_skin: Color = Color(1.0, 0.0, 0.0, 0.625)

var box_thickness: int = 2
var box_colors: Array[Color] = [
	Color.WHITE,
	Color.RED,
	Color.GREEN,
	Color.CYAN,
	Color.WHITE,
	Color.GOLD]

var sprite_color_bounds: Color = Color.BLACK
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
	
	cell_onion_skin = config.get_value(
		CFG_SECTION_CELLS, CFG_CELL_ONION, Color(1.0, 0.0, 0.0, 0.625))
	
	box_thickness = config.get_value(CFG_SECTION_BOXES, CFG_BOX_THICKNESS, 2)
	box_colors = [
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_UNK, Color.WHITE),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_HIT, Color.RED),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_HURT, Color.GREEN),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_CROP, Color.CYAN),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_UNK, Color.WHITE),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_SPAWN, Color.GOLD)
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
		CFG_SECTION_BOXES, CFG_BOX_COLOR_CROP, box_colors[BoxType.REGION])
	config.set_value(
		CFG_SECTION_BOXES, CFG_BOX_COLOR_SPAWN, box_colors[BoxType.SPAWN])
	
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
