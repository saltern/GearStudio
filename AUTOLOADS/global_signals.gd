extends Node

@warning_ignore("unused_signal")
signal menu_undo
@warning_ignore("unused_signal")
signal menu_redo

@warning_ignore("unused_signal")
signal menu_save	# Emitted by File PopupMenu, used by session_tabs.gd
@warning_ignore("unused_signal")
signal menu_save_bin # Same as above
@warning_ignore("unused_signal")
signal save_start
@warning_ignore("unused_signal")
signal save_object
@warning_ignore("unused_signal")
signal save_sub_object
@warning_ignore("unused_signal")
signal save_complete
