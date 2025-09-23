extends OptionButton

var keys: PackedStringArray = ["en"]


func _ready() -> void:
	# Add locales found in root folder
	for key in Settings.language_keys:
		if key == "en":
			continue
		
		add_item(Settings.language_keys[key])
		keys.append(key)
	
	var language_key: int = keys.find(Settings.general_language)
	
	selected = language_key
	item_selected.connect(update)


func update(item: int) -> void:
	var new_language: String = keys[item]
	Settings.set_language(new_language)
