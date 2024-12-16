extends Node

const FILENAME: String = "/file_memory.ini"

const CFG_SECTION_MENU: String = "menu"
const CFG_MENU_LOAD_DIRECTORY: String = "load_directory"
const CFG_MENU_LOAD_BINARY: String = "load_binary"
const CFG_MENU_SAVE_AS: String = "save_as"

const CFG_SECTION_SPRITE_EDITOR: String = "sprite_editor"
const CFG_SECTION_PALETTE_EDITOR: String = "palette_editor"
const CFG_SECTION_SELECT_EDITOR: String = "select_editor"

const CFG_SPRITE_IMPORT: String = "sprite_import"
const CFG_SPRITE_EXPORT: String = "sprite_export"
const CFG_PALETTE_IMPORT: String = "palette_import"
const CFG_PALETTE_EXPORT: String = "palette_export"
const CFG_SELECT_IMPORT: String = "select_import"
const CFG_SELECT_EXPORT: String = "select_export"

var config: ConfigFile = ConfigFile.new()

# Menu
var menu_load_directory: String = ""
var menu_load_binary: String = ""
var menu_save_as: String = ""

# SpriteEdit
var sprite_sprite_import: String = ""
var sprite_sprite_export: String = ""
var sprite_palette_import: String = ""
var sprite_palette_export: String = ""

# PaletteEdit
var palette_import: String = ""
var palette_export: String = ""

# SelectEdit
var select_import: String = ""
var select_export: String = ""

@onready var path: String = OS.get_executable_path().get_base_dir()


func _ready() -> void:
	load_memory()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_memory()


func load_memory() -> bool:
	if config.load(path + FILENAME) != OK:
		return false
	
	# Main menu
	menu_load_directory = config.get_value(CFG_SECTION_MENU,
		CFG_MENU_LOAD_DIRECTORY, "")
	menu_load_binary = config.get_value(CFG_SECTION_MENU,
		CFG_MENU_LOAD_BINARY, "")
	menu_save_as = config.get_value(CFG_SECTION_MENU,
		CFG_MENU_SAVE_AS, "")
	
	# SpriteEdit
	sprite_sprite_import = config.get_value(CFG_SECTION_SPRITE_EDITOR,
		CFG_SPRITE_IMPORT, "")
	sprite_sprite_export = config.get_value(CFG_SECTION_SPRITE_EDITOR,
		CFG_SPRITE_EXPORT, "")
	sprite_palette_import = config.get_value(CFG_SECTION_SPRITE_EDITOR,
		CFG_PALETTE_IMPORT, "")
	sprite_palette_export = config.get_value(CFG_SECTION_SPRITE_EDITOR,
		CFG_PALETTE_EXPORT, "")
	
	# PaletteEdit
	palette_import = config.get_value(CFG_SECTION_PALETTE_EDITOR,
		CFG_PALETTE_IMPORT, "")
	palette_export = config.get_value(CFG_SECTION_PALETTE_EDITOR,
		CFG_PALETTE_EXPORT, "")
	
	# SelectEdit
	select_import = config.get_value(CFG_SECTION_SELECT_EDITOR,
		CFG_SELECT_IMPORT, "")
	select_export = config.get_value(CFG_SECTION_SELECT_EDITOR,
		CFG_SELECT_EXPORT, "")
	
	return true


func save_memory() -> bool:
	# Main menu
	config.set_value(CFG_SECTION_MENU,
		CFG_MENU_LOAD_DIRECTORY, menu_load_directory)
	config.set_value(CFG_SECTION_MENU,
		CFG_MENU_LOAD_BINARY, menu_load_binary)
	config.set_value(CFG_SECTION_MENU,
		CFG_MENU_SAVE_AS, menu_save_as)
	
	# SpriteEdit
	config.set_value(CFG_SECTION_SPRITE_EDITOR,
		CFG_SPRITE_IMPORT, sprite_sprite_import)
	config.set_value(CFG_SECTION_SPRITE_EDITOR,
		CFG_SPRITE_EXPORT, sprite_sprite_export)
	config.set_value(CFG_SECTION_SPRITE_EDITOR,
		CFG_PALETTE_IMPORT, sprite_palette_import)
	config.set_value(CFG_SECTION_SPRITE_EDITOR,
		CFG_PALETTE_EXPORT, sprite_palette_export)
	
	# PaletteEdit
	config.set_value(CFG_SECTION_PALETTE_EDITOR,
		CFG_PALETTE_IMPORT, palette_import)
	config.set_value(CFG_SECTION_PALETTE_EDITOR,
		CFG_PALETTE_EXPORT, palette_export)
	
	# SelectEdit
	config.set_value(CFG_SECTION_SELECT_EDITOR,
		CFG_SELECT_IMPORT, select_import)
	config.set_value(CFG_SECTION_SELECT_EDITOR,
		CFG_SELECT_EXPORT, select_export)
	
	if config.save(path + FILENAME) != OK:
		return false
	
	return true
