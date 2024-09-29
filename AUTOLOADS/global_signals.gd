extends Node

signal menu_undo
signal menu_redo

signal menu_save	# Emitted by File PopupMenu, used by character_tab_list.gd
signal save_start
signal save_object
signal save_sub_object
signal save_complete
