extends Window

@export var summon_button: Button
@export var instruction_list: ItemList

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	close_requested.connect(hide)
	summon_button.pressed.connect(display)
	instruction_list.instruction_selected.connect(on_instruction_selected)


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	
	if not event.pressed:
		return
	
	if event.echo:
		return
	
	match event.keycode:
		KEY_ESCAPE:
			hide()


func display() -> void:
	show()
	position = summon_button.get_screen_position()
	position.x += 264
	position.y -= 235


func on_instruction_selected(instruction_id: int) -> void:
	hide()
	summon_button.text = ScriptInstructions.get_instruction_name(instruction_id)
	script_edit.new_instruction_type = instruction_id
