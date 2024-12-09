extends OptionButton


func _ready() -> void:
	selected = Settings.general_language
	item_selected.connect(update)


func update(new_language: Settings.Language) -> void:
	Settings.general_language = new_language
	Settings.update_locale()
