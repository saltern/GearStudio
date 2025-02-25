extends Node

const FILE_NAME: String = "res://DATA/ggpr_instructions.csv"

enum DBKeys {
	ID,
	NAME,
	ARG_SIZES,
	ARG_NAMES,
	ARG_DEFAULTS,
	ARG_SIGNED,
}

var INSTRUCTION_DB: Dictionary = {}
var task_id: int

@onready var NAME_CELLBEGIN		: String = get_instruction_name(0x00)
@onready var NAME_BACK_MOTION	: String = get_instruction_name(0x03)
@onready var NAME_SEMITRANS		: String = get_instruction_name(0x06)
@onready var NAME_SCALE			: String = get_instruction_name(0x07)
@onready var NAME_ROT			: String = get_instruction_name(0x08)
@onready var NAME_DRAW_NORMAL	: String = get_instruction_name(0x10)	# 16
@onready var NAME_DRAW_REVERSE	: String = get_instruction_name(0x11)	# 17
@onready var NAME_CELL_JUMP		: String = get_instruction_name(0x27)	# 39
@onready var NAME_VISUAL		: String = get_instruction_name(0x45)	# 69
@onready var NAME_END_ACTION	: String = get_instruction_name(0xFF)	# 255


# DB needs to be complete before _ready() for above instruction names
func _enter_tree() -> void:
	task_id = WorkerThreadPool.add_task(build_database)


func _ready() -> void:
	var db_file: FileAccess = FileAccess.open(
		OS.get_executable_path().get_base_dir() + "/inst_db.dat",
		FileAccess.WRITE
	)
	
	db_file.store_var(INSTRUCTION_DB, true)
	db_file.close()


func _physics_process(_delta: float) -> void:
	if WorkerThreadPool.is_task_completed(task_id):
		WorkerThreadPool.wait_for_task_completion(task_id)
		set_physics_process(false)


func build_database() -> void:	
	Status.set_status.call_deferred("STATUS_INSTRUCTION_DB_START")
	
	#var path: String = OS.get_executable_path().get_base_dir()
	#path += FILE_NAME
	if not FileAccess.file_exists(FILE_NAME):
		Status.set_status.call_deferred("STATUS_INSTRUCTION_DB_FILE_NOT_FOUND")
		return
	
	var db_read := FileAccess.open(FILE_NAME, FileAccess.READ)
	
	# Header
	db_read.get_csv_line()
	
	# Grab instruction data
	while not db_read.eof_reached():
		var line := db_read.get_csv_line()
		
		var inst_id: int = line[DBKeys.ID].to_int()
		var inst_name: String = line[DBKeys.NAME]
		
		var inst_arg_names: PackedStringArray = \
			line[DBKeys.ARG_NAMES].split("\n")
		
		var key_arg_sizes: PackedStringArray = \
			line[DBKeys.ARG_SIZES].split("\n")
		
		var inst_arg_sizes: PackedInt32Array = []
		for arg in key_arg_sizes:
			inst_arg_sizes.append(arg.to_int())
		
		var key_arg_defaults: PackedStringArray = \
			line[DBKeys.ARG_DEFAULTS].split("\n")
		
		var inst_arg_defaults: PackedInt32Array = []
		for arg in key_arg_defaults:
			inst_arg_defaults.append(arg.to_int())
		
		var key_arg_signed: PackedStringArray = \
			line[DBKeys.ARG_SIGNED].split("\n")
		
		var inst_arg_signed: int = 0
		
		# Make into bit flags
		for bit in key_arg_signed.size():
			var flag: int = key_arg_signed[bit].to_int() << bit
			inst_arg_signed |= flag
		
		var arguments: Array[Dictionary]
		
		for argument in inst_arg_sizes.size():
			var new_argument: Dictionary = {}
			new_argument.display_name = inst_arg_names[argument]
			new_argument.size = inst_arg_sizes[argument]
			new_argument.value = inst_arg_defaults[argument]
			new_argument.signed = bool(inst_arg_signed & (1 << argument))
			arguments.append(new_argument)
		
		INSTRUCTION_DB[inst_id] = {
			"id": inst_id,
			"display_name": inst_name,
			"arguments": arguments,
		}
	
	status_build_complete.bind(INSTRUCTION_DB.size()).call_deferred()


func status_build_complete(count: int) -> void:
	Status.set_status(tr("STATUS_INSTRUCTION_DB_FINISH").format({
		"count": count
	}))


func get_instruction(id: int) -> Instruction:
	var new_instruction: Instruction = Instruction.new()
	var ref_instruction: Dictionary = INSTRUCTION_DB[id]
	
	new_instruction.id = id
	new_instruction.display_name = ref_instruction.display_name
	
	for argument in ref_instruction.arguments:
		var new_argument := InstructionArgument.new()
		new_argument.signed = argument.signed
		new_argument.value = argument.value
		new_argument.size = argument.size
		new_instruction.arguments.append(new_argument)
	
	return new_instruction


func get_instruction_name(id: int) -> String:
	if not INSTRUCTION_DB.has(id):
		return "SCRIPT_INSTRUCTION_NOT_FOUND"
	
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
		new_arg.signed = ref_arg.signed
		
		match new_arg.size:
			1:
				if new_arg.signed:
					new_arg.value = data.decode_s8(cursor)
				else:
					new_arg.value = data.decode_u8(cursor)
				
				cursor += 0x01
			2:
				if new_arg.signed:
					new_arg.value = data.decode_s16(cursor)
				else:
					new_arg.value = data.decode_u16(cursor)
				
				cursor += 0x02
			4:
				if new_arg.signed:
					new_arg.value = data.decode_s32(cursor)
				else:
					new_arg.value = data.decode_u32(cursor)
				
				cursor += 0x04
		
		
		new_instruction.arguments.append(new_arg)
	
	return new_instruction


func get_argument_name(instruction_id: int, argument_index: int) -> String:
	return INSTRUCTION_DB[instruction_id].arguments[argument_index].display_name
