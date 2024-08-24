extends GridContainer


func _ready() -> void:
	for index in 256:
		add_child(PaletteColor.new())

	SharedData.changed_palette.connect(update_palette)
	SharedData.get_palette(0)


func update_palette() -> void:
	for index in 256:
		var this_color: Color = Color8(
			SharedData.this_palette.palette[4 * index + 0],
			SharedData.this_palette.palette[4 * index + 1],
			SharedData.this_palette.palette[4 * index + 2],
			SharedData.this_palette.palette[4 * index + 3])
		
		get_child(index).color = this_color
