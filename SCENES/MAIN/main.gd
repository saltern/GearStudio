extends Control


func _ready() -> void:
	@warning_ignore("narrowing_conversion")
	var max_fps: int = DisplayServer.screen_get_refresh_rate()
	
	if max_fps < 30:
		max_fps = 60
	
	Engine.max_fps = max_fps
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	if not Handshake.status:
		# For some godforsaken reason, when the handshake fails, it's telling
		# me that the warning window does not exist. Using a script directly
		# on a Window or AcceptDialog also fails. I can't think of any reason
		# for these things to happen, so I'll just create a dialog at runtime,
		# entirely by code.
		
		var dialog: AcceptDialog = AcceptDialog.new()
		dialog.initial_position = \
			Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
		
		dialog.title = "Handshake failed!"
		dialog.dialog_text = "Gear Studio was unable to communicate with ggpr_bin.dll.
Either the file was not found, or it could not be loaded.
The program will not work without it!"
		
		add_child(dialog)
		dialog.show()
		
		var screen_center: Vector2i = DisplayServer.screen_get_size() / 2
		dialog.position = screen_center - Vector2i(196, 79)
