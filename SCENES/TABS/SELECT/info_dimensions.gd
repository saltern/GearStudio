extends Label


@onready var select_edit: SelectEdit = owner


func _ready() -> void:
	select_edit.select_changed.connect(update)


func update() -> void:
	var width: int = select_edit.obj_data["select_width"]
	var height: int = select_edit.obj_data["select_height"]
	
	text = "%s x %s" % [width, height]
