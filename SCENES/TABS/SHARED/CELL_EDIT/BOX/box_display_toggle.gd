extends CheckButton

@export var box_draw_node: Control
@export var editable_parent: Control


func _ready() -> void:
	toggled.connect(toggle)


func toggle(new_value: bool) -> void:
	box_draw_node.visible = new_value
	editable_parent.visible = new_value
