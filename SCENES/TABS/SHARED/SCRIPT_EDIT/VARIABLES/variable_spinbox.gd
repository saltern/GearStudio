extends SteppingSpinBox

# Guh
@export_enum(
	"walk_fwd_x_speed",
	"walk_bwd_x_speed",
	"dash_x_speed",
	"backdash_x_speed",
	"backdash_y_speed",
	"backdash_gravity",
	"jump_fwd_x_speed",
	"jump_bwd_x_speed",
	"jump_y_speed",
	"jump_gravity",
	"sjump_fwd_x_speed",
	"sjump_bwd_x_speed",
	"sjump_y_speed",
	"sjump_gravity",
	"dash_acceleration",
	"dash_resist",
	"homing_jump_y_max",
	"homing_jump_x_max",
	"homing_jump_x_resist",
	"homing_target_y_offset",
	"airdash_height",
	"airdash_fwd_time",
	"airdash_bwd_time",
	"faint_point",
	"defense_point",
	"konjo",
	"kaishin",
	"defense_gravity",
	"airdash_count",
	"jump_count",
	"airdash_fwd_atk_time",
	"airdash_bwd_atk_time",
	"tension_walk",
	"tension_jump",
	"tension_dash",
	"tension_airdash",
	"gc_gauge_def_point",
	"gc_gauge_recovery",
	"tension_ib",
) var variable: String

@onready var var_edit: VariableEdit = owner
@onready var play_data: PlayData = var_edit.play_data


func _ready() -> void:
	min_value = -32768
	max_value = 32767
	set_value_no_signal(play_data.variables.get(variable))
	value_changed.connect(on_value_changed)
	
	var_edit.var_changed.connect(on_var_changed)


func on_value_changed(new_value: float) -> void:
	var_edit.set_variable(variable, new_value as int)


func on_var_changed(var_name: String, new_value: int) -> void:
	if var_name != variable:
		return
	
	set_value_no_signal(new_value)
