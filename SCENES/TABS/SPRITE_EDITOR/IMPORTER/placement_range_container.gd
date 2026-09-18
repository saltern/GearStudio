extends HBoxContainer

@export var dialog: SpriteImportDialog


func _ready() -> void:
	dialog.placement_method_set.connect(check_visibility.unbind(1))
	dialog.placement_manual_range_set.connect(check_visibility.unbind(1))


func check_visibility() -> void:
	visible = (
		dialog.placement_method == SpriteImportDialog.PlacementMethod.REPLACE &&
		dialog.placement_manual_range == true
	)
