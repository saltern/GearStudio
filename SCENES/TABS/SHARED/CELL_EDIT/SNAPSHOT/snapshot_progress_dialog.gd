extends Window

@export var progress_label: Label

@onready var cell_edit: CellEdit = owner

var snapshot_count: int = 0
var snapshot_target: int = 0


func _ready() -> void:
	cell_edit.cell_snapshots_start.connect(display)
	cell_edit.cell_snapshot_taken.connect(on_snapshot_taken)
	cell_edit.cell_snapshots_done.connect(hide)


func display(total_count: int) -> void:
	snapshot_count = 0
	snapshot_target = total_count
	update()
	show()


func update() -> void:
	progress_label.text = "%s / %s" % [snapshot_count, snapshot_target]


func on_snapshot_taken() -> void:
	snapshot_count += 1
	update()
