extends Node

@warning_ignore_start("unused_signal")
signal display_window

# General
signal language_changed

# Customization
signal custom_color_bg_a_changed
signal custom_color_bg_b_changed
signal custom_color_status_changed

# Cells
signal draw_origin_changed
signal origin_type_changed
signal onion_color_changed
signal guide_color_changed

# Sprites
signal sprite_bounds_color_changed

# Misc
signal max_undo_changed

const FILENAME: String = "/gearstudio.ini"

const LOCALE_PATH: String = "/locale"
var language_keys: Dictionary = {
	"en": "English",
}

const CFG_SECTION_GENERAL: String = "general"
const CFG_GENERAL_LANGUAGE: String = "language"

const CFG_SECTION_CUSTOM: String = "customization"
const CFG_CUSTOM_BG_A: String = "color_bg_a"
const CFG_CUSTOM_BG_B: String = "color_bg_b"
const CFG_CUSTOM_STATUS: String = "color_status"

const CFG_SECTION_CELLS: String = "cells"
const CFG_CELL_ORIGIN: String = "draw_origin"
const CFG_CELL_ORIGIN_TYPE: String = "origin_type"
const CFG_CELL_ONION: String = "onion_color"
const CFG_CELL_GUIDE: String = "guide_color"
const CFG_CELL_SNAPSHOT: String = "snapshot_format"

const CFG_SECTION_BOXES: String = "boxes"
const CFG_BOX_THICKNESS: String = "thickness"
const CFG_BOX_COLOR_HIT: String = "color_hitbox"
const CFG_BOX_COLOR_HURT: String = "color_hurtbox"
const CFG_BOX_COLOR_CROP_B: String = "color_region_b"
const CFG_BOX_COLOR_CROP_F: String = "color_region_f"
const CFG_BOX_COLOR_COLL_EXT: String = "color_collision"
const CFG_BOX_COLOR_SPAWN: String = "color_spawn"
const CFG_BOX_COLOR_UNK: String = "color_unknown"

const CFG_SECTION_SPRITES: String = "sprites"
const CFG_SPRITE_COLOR_BOUNDS: String = "color_bounds"
const CFG_SPRITE_REINDEX: String = "reindex"

const CFG_SECTION_PALETTES: String = "palettes"
const CFG_PAL_GRAD_REINDEX: String = "gradient_reindex"

const CFG_SECTION_MISC: String = "misc"
const CFG_MISC_MAX_UNDO: String = "max_undo"
const CFG_MISC_REOPEN: String = "allow_reopen"

enum BoxType {
	HITBOX_ALT,			# 0
	HITBOX,				# 1
	HURTBOX,			# 2
	REGION_B,			# 3
	COLLISION_EXTEND,	# 4
	SPAWN,				# 5
	REGION_F,			# 6
	UNKNOWN,			# 7+
}

enum SnapshotFormat {
	PNG,
	PSD,
	BOTH,
}

var general_language: String = "en"

var custom_color_bg_a: Color = Color8(0x60, 0x60, 0x60)
var custom_color_bg_b: Color = Color8(0x40, 0x40, 0x40)
var custom_color_status: Color = Color8(0x1A, 0x1A, 0x1A)

var cell_draw_origin: bool = true
var cell_origin_type: int = 0
var cell_onion_skin: Color = Color8(255, 0, 0, 0xA0)
var cell_guide: Color = Color8(255, 0, 0, 0xA0)
var cell_snapshot_format: SnapshotFormat = SnapshotFormat.PNG

var box_thickness: int = 2
var box_colors: Array[Color] = [
	Color.RED,
	Color.RED,
	Color.GREEN,
	Color.CORNFLOWER_BLUE,
	Color.PURPLE,
	Color.GOLD,
	Color.CYAN,
	Color.WHITE,
]

var sprite_color_bounds: Color = Color.BLACK:
	set(value):
		sprite_color_bounds = value
		sprite_bounds_color_changed.emit()

var pal_gradient_reindex: bool = false

var misc_max_undo: int = 200
var misc_allow_reopen: bool = true

var config: ConfigFile = ConfigFile.new()


@onready var path: String = OS.get_executable_path().get_base_dir()


func _ready() -> void:
	load_config()
	load_locales()
	update_locale()


func load_locales() -> void:
	# No "locale" directory
	if not DirAccess.dir_exists_absolute(path + LOCALE_PATH):
		return
	
	var file_list := DirAccess.get_files_at(path + LOCALE_PATH)
	
	for file in file_list:
		var locale: PackedStringArray = file.split(".")
		
		# Ignore files with invalid names
		if locale.size() < 2:
			continue
		
		var this_path: String = path + LOCALE_PATH + "/" + file
		
		# Generate Translation...
		var translation: Translation = Translation.new()
		translation.locale = locale[0]
		
		var csv_read := FileAccess.open(this_path, FileAccess.READ)
		
		# Keys
		var keys: Dictionary = {}
		var count: int = 0
		for key in csv_read.get_csv_line():
			keys[key] = count
			count += 1
		
		# Ignore bad files
		if not keys.has("key") or not keys.has("translation"):
			continue
		
		var column_key: int = keys["key"]
		var column_translation: int = keys["translation"]
		
		while not csv_read.eof_reached():
			var line: PackedStringArray = csv_read.get_csv_line()
			
			# Ignore empty messages
			if line[column_key].is_empty():
				continue
			
			translation.add_message(
				line[column_key], line[column_translation]
			)
		
		# Register
		language_keys[locale[0]] = locale[1]
		TranslationServer.add_translation(translation)


func update_locale() -> void:
	TranslationServer.set_locale(general_language)
	language_changed.emit()


func load_config() -> bool:
	if config.load(path + FILENAME) != OK:
		return false
	
	general_language = config.get_value(
		CFG_SECTION_GENERAL, CFG_GENERAL_LANGUAGE, general_language)
	
	custom_color_status = config.get_value(
		CFG_SECTION_CUSTOM, CFG_CUSTOM_STATUS, custom_color_status)
	custom_color_bg_a = config.get_value(
		CFG_SECTION_CUSTOM, CFG_CUSTOM_BG_A, custom_color_bg_a)
	custom_color_bg_b = config.get_value(
		CFG_SECTION_CUSTOM, CFG_CUSTOM_BG_B, custom_color_bg_b)
	
	cell_draw_origin = config.get_value(
		CFG_SECTION_CELLS, CFG_CELL_ORIGIN, true)
	cell_origin_type = config.get_value(
		CFG_SECTION_CELLS, CFG_CELL_ORIGIN_TYPE, 0)
	cell_onion_skin = config.get_value(
		CFG_SECTION_CELLS, CFG_CELL_ONION, cell_onion_skin)
	cell_guide = config.get_value(
		CFG_SECTION_CELLS, CFG_CELL_GUIDE, cell_guide)
	cell_snapshot_format = config.get_value(
		CFG_SECTION_CELLS, CFG_CELL_SNAPSHOT, cell_snapshot_format)
	
	box_thickness = config.get_value(CFG_SECTION_BOXES, CFG_BOX_THICKNESS, 2)
	box_colors = [
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_HIT, box_colors[0]),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_HIT, box_colors[1]),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_HURT, box_colors[2]),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_CROP_B, box_colors[3]),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_COLL_EXT, box_colors[4]),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_SPAWN, box_colors[5]),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_CROP_F, box_colors[6]),
		config.get_value(CFG_SECTION_BOXES, CFG_BOX_COLOR_UNK, box_colors[7]),
	]
	
	sprite_color_bounds = config.get_value(
		CFG_SECTION_SPRITES, CFG_SPRITE_COLOR_BOUNDS, sprite_color_bounds)
	
	pal_gradient_reindex = config.get_value(
		CFG_SECTION_PALETTES, CFG_PAL_GRAD_REINDEX, pal_gradient_reindex)
	
	misc_max_undo = config.get_value(
		CFG_SECTION_MISC, CFG_MISC_MAX_UNDO, misc_max_undo)
	misc_allow_reopen = config.get_value(
		CFG_SECTION_MISC, CFG_MISC_REOPEN, misc_allow_reopen)
	
	return true


func save_config() -> bool:
	config.set_value(
		CFG_SECTION_GENERAL, CFG_GENERAL_LANGUAGE, general_language)
		
	config.set_value(
		CFG_SECTION_CUSTOM, CFG_CUSTOM_STATUS, custom_color_status)
	config.set_value(
		CFG_SECTION_CUSTOM, CFG_CUSTOM_BG_A, custom_color_bg_a)
	config.set_value(
		CFG_SECTION_CUSTOM, CFG_CUSTOM_BG_B, custom_color_bg_b)
	
	config.set_value(
		CFG_SECTION_CELLS, CFG_CELL_ORIGIN, cell_draw_origin)
	config.set_value(
		CFG_SECTION_CELLS, CFG_CELL_ORIGIN_TYPE, cell_origin_type)
	config.set_value(
		CFG_SECTION_CELLS, CFG_CELL_ONION, cell_onion_skin)
	config.set_value(
		CFG_SECTION_CELLS, CFG_CELL_GUIDE, cell_guide)
	config.set_value(
		CFG_SECTION_CELLS, CFG_CELL_SNAPSHOT, cell_snapshot_format)
	
	config.set_value(
		CFG_SECTION_BOXES, CFG_BOX_THICKNESS, box_thickness)
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
		CFG_SECTION_BOXES, CFG_BOX_COLOR_UNK, box_colors[BoxType.UNKNOWN])
	
	config.set_value(
		CFG_SECTION_SPRITES, CFG_SPRITE_COLOR_BOUNDS, sprite_color_bounds)
	
	config.set_value(
		CFG_SECTION_PALETTES, CFG_PAL_GRAD_REINDEX, pal_gradient_reindex)
	
	config.set_value(CFG_SECTION_MISC, CFG_MISC_MAX_UNDO, misc_max_undo)
	config.set_value(CFG_SECTION_MISC, CFG_MISC_REOPEN, misc_allow_reopen)
	
	if config.save(path + FILENAME) != OK:
		return false
		
	return true
