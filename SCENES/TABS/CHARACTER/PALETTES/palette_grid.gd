extends GridContainer

@export var color_picker: ColorPicker
@export var preview: TextureRect

var index_hovered: int = 0
var index_active: int = 0


func _ready() -> void:
	color_picker.color_changed.connect(update_color)
	color_picker.color = SharedData.get_color(index_active)
	
	for index in 256:
		var new_color := PaletteColor.new()
		new_color.hovered.connect(on_color_hover)
		new_color.clicked.connect(on_color_click)
		add_child(new_color)
		

	SharedData.changed_palette.connect(update_palette)
	SharedData.load_palette(0)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	# Hovered color
	if index_hovered > -1:
		draw_rect(Rect2(
			17 * (index_hovered % 16), 17 * (index_hovered / 16), 17, 17),
			Color.CYAN, false, 1)
	
	# Active color
	draw_rect(Rect2(
		17 * (index_active % 16), 17 * (index_active / 16), 17, 17),
		Color.RED, false, 1)


func update_palette() -> void:
	for index in 256:		
		get_child(index).color = SharedData.get_color(index)


func update_color(new_color: Color) -> void:
	var color: PaletteColor = get_child(index_active)
	color.color = new_color
	
	SharedData.set_color(index_active, new_color)
	preview.update_palette()


func on_color_hover(index: int) -> void:
	index_hovered = index
	preview.material.set_shader_parameter("highlight_index", index)


func on_color_click(index: int) -> void:
	index_active = index
	color_picker.color = SharedData.get_color(index)
