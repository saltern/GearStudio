extends Node
@warning_ignore_start("unused_signal")

signal menu_undo
signal menu_redo

signal menu_save		# Emitted by File PopupMenu, used by session_tabs.gd
signal menu_save_bin	# Same as above

signal save_start
signal save_object
signal save_sub_object
signal save_complete

signal decryption_start
signal decryption_end

signal progress_window_start
signal progress_window_progress
signal progress_window_finish

signal sprite_importer_on


func progress_show(text: String, count: int) -> void:
	progress_window_start.emit.call_deferred(text, count)


func progress_advance() -> void:
	progress_window_progress.emit.call_deferred()


func progress_finish() -> void:
	progress_window_finish.emit.call_deferred()


func sprite_importer_open(session: Session, object: BinSpriteBlock) -> void:
	sprite_importer_on.emit(session, object)
