extends CheckButton

@export var picker: ColorPicker

@onready var provider: PaletteProvider = owner.provider


func _ready() -> void:
	toggled.connect(update)


func update(toggled_on: bool) -> void:
	provider.by_channel = toggled_on
	if toggled_on:
		picker.color_mode = ColorPicker.MODE_RGB
		picker.color_modes_visible = false
	else:
		picker.color_modes_visible = true
