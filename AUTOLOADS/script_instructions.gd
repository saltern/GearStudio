extends Node

const FILE_NAME: String = "/ggpr_instructions.csv"

const NAME_CELLBEGIN		: String = "CellBegin"			# 0
const NAME_BACK_MOTION		: String = "BACK_MOTION"		# 3
const NAME_SCALE			: String = "SCALE"				# 7
const NAME_DRAW_NORMAL		: String = "DRAW_NORMAL"		# 16
const NAME_DRAW_REVERSE		: String = "DRAW_REVERSE"		# 17

enum DBKeys {
	ID,
	NAME,
	ARG_SIZES,
	ARG_NAMES,
	ARG_DEFAULTS,
}

var INSTRUCTION_DB: Dictionary = {}
var task_id: int


func _ready() -> void:
	task_id = WorkerThreadPool.add_task(build_database)


func _physics_process(_delta: float) -> void:
	if WorkerThreadPool.is_task_completed(task_id):
		WorkerThreadPool.wait_for_task_completion(task_id)
		set_physics_process(false)


func build_database() -> void:	
	Status.set_status.call_deferred("Building Script Instruction Database...")
	
	var path: String = OS.get_executable_path().get_base_dir()
	path += FILE_NAME
	if not FileAccess.file_exists(path):
		print("Instruction DB file not found!")
		return
	
	var db_read := FileAccess.open(path, FileAccess.READ)
	
	# Header
	#var keys = db_read.get_csv_line()
	
	# Grab instruction data
	while not db_read.eof_reached():
		var line := db_read.get_csv_line()
		var inst_id: int = line[DBKeys.ID].to_int()
		var inst_name: String = line[DBKeys.NAME]
		
		var inst_arg_names: PackedStringArray = \
			line[DBKeys.ARG_NAMES].split(";")
		
		var key_arg_sizes: PackedStringArray = \
			line[DBKeys.ARG_SIZES].split(";")
		
		var inst_arg_sizes: PackedInt32Array = []
		for arg in key_arg_sizes:
			inst_arg_sizes.append(arg.to_int())
		
		var key_arg_defaults: PackedStringArray = \
			line[DBKeys.ARG_DEFAULTS].split(";")
		
		var inst_arg_defaults: PackedInt32Array = []
		for arg in key_arg_defaults:
			inst_arg_defaults.append(arg.to_int())
		
		var new_instruction := Instruction.new()
		new_instruction.id = inst_id
		new_instruction.display_name = inst_name
		
		for argument in inst_arg_sizes.size():
			var new_argument := InstructionArgument.new()
			new_argument.display_name = inst_arg_names[argument]
			new_argument.size = inst_arg_sizes[argument]
			new_argument.value = inst_arg_defaults[argument]
			new_instruction.arguments.append(new_argument)
		
		INSTRUCTION_DB[inst_id] = new_instruction
	
	Status.set_status.call_deferred(
		"Script Instruction DB build complete. Entries: %s."
		% INSTRUCTION_DB.size()
	)
			

func get_instruction(id: int) -> Instruction:
	return INSTRUCTION_DB[id].duplicate(true)


func get_instruction_name(id: int) -> String:
	return INSTRUCTION_DB[id].display_name


func get_instruction_size(id: int) -> int:
	var size: int = 1 # Instruction ID: 1 byte
	
	for argument in (INSTRUCTION_DB[id] as Instruction).arguments:
		size += argument.size
	
	return size


func get_instruction_from_data(data: PackedByteArray) -> Instruction:
	var cursor: int = 0x00
	
	var id: int = data.decode_u8(cursor)
	cursor += 0x01
	
	var new_instruction: Instruction = Instruction.new()
	var reference: Instruction = INSTRUCTION_DB[id]
	
	new_instruction.id = reference.id
	new_instruction.display_name = reference.display_name
	
	for index in reference.arguments.size():
		var ref_arg: InstructionArgument = reference.arguments[index]
		var new_arg: InstructionArgument = InstructionArgument.new()
		
		new_arg.display_name = ref_arg.display_name
		new_arg.size = ref_arg.size
		
		match new_arg.size:
			1:
				new_arg.value = data.decode_u8(cursor)
				cursor += 0x01
			2:
				new_arg.value = data.decode_u16(cursor)
				cursor += 0x02
		
		new_instruction.arguments.append(new_arg)
	
	return new_instruction
