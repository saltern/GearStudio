extends Control


func _ready() -> void:
	@warning_ignore("narrowing_conversion")
	var max_fps: int = DisplayServer.screen_get_refresh_rate()
	
	if max_fps < 30:
		max_fps = 60
	
	Engine.max_fps = max_fps
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
