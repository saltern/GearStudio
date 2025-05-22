extends CheckButton

@onready var provider: PaletteProvider = owner.provider


func _ready() -> void:
	toggled.connect(update)


func update(toggled_on: bool) -> void:
	provider.by_channel = toggled_on
