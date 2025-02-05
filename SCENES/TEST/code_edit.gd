class_name BinScriptEdit extends CodeEdit

@export var completion_timer: Timer
@export var explanation: Label

signal inst_cell_begin

var latest_line: int = 0
var candidates: Dictionary = {}

@onready var SI := ScriptInstructions


func _ready() -> void:
	code_completion_enabled = true
	text_changed.connect(test_completion)
	lines_edited_from.connect(instruction_check.unbind(1))
	caret_changed.connect(caret_moved)
	completion_timer.timeout.connect(completion_timeout)


func build_candidates() -> void:
	for index in ScriptInstructions.INSTRUCTION_DB:
		var candidate: String = ScriptInstructions.get_instruction_name(index)
		add_code_completion_option(
			CodeEdit.KIND_PLAIN_TEXT, candidate, "%s, " % candidate
		)
	
	update_code_completion_options(true)


func _request_code_completion(_force: bool) -> void:
	build_candidates()


func test_completion() -> void:
	var tokens: PackedStringArray = get_tokens(get_line(get_caret_line()))
	var token_count: int = tokens.size()
	
	if token_count == 1:
		set_code_hint("")
		completion_timer.start()
	else:
		show_hints(tokens)


func completion_timeout() -> void:
	request_code_completion(true)


func show_hints(tokens: PackedStringArray) -> void:
	match get_instruction_id(tokens):
		0:
			match tokens.size():
				2:
					set_code_hint("Duration: 0 - 255")
				3:
					set_code_hint("Cell #: 0 - 65535")
		
		0xFF:
			match tokens.size():
				2:
					set_code_hint("Mode:
						0: Nothing
						1: Unknown
						2: Unknown
						3: Loop
						4: Relative action jump"
					)
				3:
					match tokens[1].to_int():
						_:
							set_code_hint("(Unused by this mode)")
						4:
							set_code_hint("Relative jump offset")
		_:
			set_code_hint("")


func get_tokens(line: String) -> PackedStringArray:
	return line.split(",")


func get_instruction_id(tokens: PackedStringArray) -> int:
	if tokens.size() < 1:
		return -1
	
	match tokens[0]:
		SI.NAME_CELLBEGIN:
			return 0
		SI.NAME_END_ACTION:
			return 0xFF
	
	return -1


func instruction_check(at_line: int) -> void:
	var tokens: PackedStringArray = get_tokens(get_line(at_line))
	
	match get_instruction_id(tokens):
		0:
			explanation.display_explanation(0)
			
			if tokens.size() < 3:
				return
			
			inst_cell_begin.emit(tokens[1].to_int(), tokens[2].to_int())
		
		_:
			explanation.display_explanation(-1)


func caret_moved() -> void:
	var new_line: int = get_caret_line()
	if new_line == latest_line:
		return
	
	instruction_check(new_line)
	latest_line = new_line
