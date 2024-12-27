extends Node
@warning_ignore_start("unused_signal")

signal menu_undo
signal menu_redo

signal menu_save		# Emitted by File PopupMenu, used by session_tabs.gd
signal menu_save_bin	# Same as above

# session_tabs.gd::save_binary() -> ScriptEdit::script_save()
signal save_scripts

signal save_start
signal save_object
signal save_sub_object
signal save_complete
