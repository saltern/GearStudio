extends TabContainer

@export var load_dialog: FileDialog
@export var character_scene: PackedScene


func _ready() -> void:
	load_dialog.dir_selected.connect(load_character)
	tab_changed.connect(on_tab_changed)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_undo"):
		SessionData.undo()


func load_character(path: String) -> void:
	var new_character: Control = character_scene.instantiate()
	new_character.load_from_path(path)
	
	var new_name: String = "%s - %s" % [
		get_child_count(),
		path.split("\\")[-1]]
	
	new_character.name = new_name
	add_child(new_character)


func on_tab_changed(new_tab: int) -> void:
	SessionData.tab_load(new_tab)
