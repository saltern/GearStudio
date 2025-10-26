extends CheckButton

@export var control_index: HBoxContainer
@export var control_alpha: HBoxContainer
@export var control_reindex: CheckButton

@onready var sprite_edit: SpriteEdit = owner


func _ready() -> void:
	visibility_changed.connect(update)
	toggled.connect(update.unbind(1))
	update()


func update() -> void:
	SpriteExport.set_palette_include(button_pressed)
	
	if sprite_edit.obj_data.has("palettes"):
		control_index.visible = button_pressed
		
	control_alpha.visible = button_pressed
	control_reindex.visible = button_pressed
