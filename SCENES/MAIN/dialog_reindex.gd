extends ConfirmationDialog

@export var remember: CheckButton


func _ready() -> void:
	GlobalSignals.prompt_reindex_mode.connect(on_prompt_reindex_mode)
	canceled.connect(on_canceled)
	confirmed.connect(on_confirmed)


func on_prompt_reindex_mode() -> void:
	match Settings.pal_reindex_mode:
		Settings.ReindexMode.ASK:
			show()
			
		Settings.ReindexMode.ALWAYS:
			# Not proud of this
			await get_tree().physics_frame
			SessionData.set_reindex_player(true)
			
		Settings.ReindexMode.NEVER:
			await get_tree().physics_frame
			SessionData.set_reindex_player(false)


func on_canceled() -> void:
	if remember.button_pressed:
		Settings.set_palette_reindex_mode(Settings.ReindexMode.NEVER)
	SessionData.set_reindex_player(false)


func on_confirmed() -> void:
	if remember.button_pressed:
		Settings.set_palette_reindex_mode(Settings.ReindexMode.ALWAYS)
	SessionData.set_reindex_player(true)
