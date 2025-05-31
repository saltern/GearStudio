extends "res://SCENES/TABS/SHARED/CELL_EDIT/dialog.gd"

@export_group("Range")
@export var from: SteppingSpinBox
@export var to: SteppingSpinBox

@export_group("Palette")
@export var palette_mode: OptionButton
@export var pal_browse_button: Button
@export var pal_file_dialog: FileDialog
@export var pal_error_dialog: AcceptDialog
@export var snapshot_button: Button

@export_group("")
@export var preview: CellSpriteDisplay

var override_pal: PackedByteArray = []


func _ready() -> void:
	palette_mode.item_selected.connect(on_pal_mode_set)
	pal_browse_button.pressed.connect(pal_file_dialog.show)
	pal_browse_button.hide()
	pal_file_dialog.file_selected.connect(on_pal_file_selected)
	snapshot_button.pressed.connect(on_snapshot_button_pressed)


func on_pal_mode_set(pal_mode: int) -> void:
	override_pal = []
	pal_browse_button.visible = pal_mode == 2
	
	if pal_mode == 1:
		for index in 256:
			for channel in 3:
				override_pal.append(index)
			override_pal.append(255)
	
	preview.override_pal = override_pal
	preview.reload_palette()


func on_pal_file_selected(path: String) -> void:
	var new_palette: BinPalette
	
	match path.get_extension().to_lower():
		"bin":
			new_palette = BinPalette.from_bin_file(path)
		"act":
			new_palette = BinPalette.from_act_file(path)
		"png":
			new_palette = BinPalette.from_png_file(path)
		"bmp":
			new_palette = BinPalette.from_bmp_file(path)
		_:
			pal_error_dialog.show()
			return
	
	if not new_palette:
		pal_error_dialog.show()
		pal_error_dialog.grab_focus()
		return
	
	override_pal = new_palette.palette
	preview.override_pal = override_pal
	preview.reload_palette()


func on_snapshot_button_pressed() -> void:
	cell_edit.snapshot_range(from.value, to.value, override_pal)
