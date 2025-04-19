extends Window

@export var progress_label: Label

var sprite_count: int = 0
var sprites_done: int = 0


func _ready() -> void:
	SpriteImport.sprite_import_started.connect(on_sprite_import_started)
	SpriteImport.sprite_importer.sprite_imported.connect(on_sprite_imported)
	SpriteImport.sprite_placement_started.connect(on_sprite_placement_started)
	SpriteImport.sprite_placement_finished.connect(on_sprite_placement_finished)
	set_process(false)


func _process(_delta: float) -> void:
	update_progress()


func on_sprite_import_started(for_session: int, object_name: String) -> void:
	if for_session != owner.session_id:
		return
	
	sprite_count = SpriteImport.import_list.size()
	sprites_done = 0
	set_process(true)
	update_progress()
	show()


func on_sprite_placement_started() -> void:
	progress_label.text = "Placing sprites..."


func on_sprite_placement_finished() -> void:
	set_process(false)
	hide()


func on_sprite_imported() -> void:
	sprites_done += 1


func update_progress() -> void:
	progress_label.text = "%s / %s" % [sprites_done, sprite_count]
