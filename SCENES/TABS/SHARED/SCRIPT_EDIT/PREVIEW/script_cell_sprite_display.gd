extends CellSpriteDisplay

signal scale_set
signal rotation_set

@export var ignore_visual_toggle: CheckButton

@export var sprite_scale: Node2D
@export var sprite_scale_y: Node2D

var angle: int = 0
var scale_x: int = -1
var scale_y: int = -1

var ignore_visual: bool = false

var anim: ScriptAnimationPlayer


func _ready() -> void:
	SessionData.palette_changed.connect(on_palette_changed)
	anim.action_loaded.connect(disable_visual_1)
	anim.cell_clear.connect(unload_sprite)
	anim.inst_cell.connect(on_cell)
	anim.inst_semitrans.connect(on_semitrans)
	anim.inst_scale.connect(on_scale)
	anim.inst_rotate.connect(on_rotate)
	anim.inst_draw_normal.connect(on_draw_normal)
	anim.inst_draw_reverse.connect(on_draw_reverse)
	anim.inst_visual.connect(on_visual)
	ignore_visual_toggle.toggled.connect(toggle_visual)


func toggle_visual(enabled: bool) -> void:
	if enabled and not visible:
		visible = true
	
	ignore_visual = enabled


#region INSTRUCTION SIMULATION
func disable_visual_1() -> void:
	visual_1 = false


func on_cell(index: int) -> void:
	if provider.cell_get_count() > index:
		var this_cell: Cell = provider.cell_get(index)
		load_cell(this_cell)
	else:
		unload_sprite()


func on_semitrans(mode: int, value: int) -> void:
	(material as ShaderMaterial).set_shader_parameter("blend_mode", mode)
	(material as ShaderMaterial).set_shader_parameter("blend_value", value)


func on_scale(mode: int, value: int) -> void:
	match mode:
		0:
			scale_x = value
		1:
			scale_y = value
		2:
			scale_x += value
		3:
			scale_y += value
		4:
			scale_x += randi_range(0, pow(256, 2) - 1) & value
		5:
			scale_y += randi_range(0, pow(256, 2) - 1) & value
		6:
			scale_x = (scale_x * float(value) / 100.00)
		7:
			scale_y = (scale_y * float(value) / 100.00)
	
	# Apply
	if scale_x == -1:
		sprite_scale.scale.x = 1.0
	else:
		sprite_scale.scale.x = float(scale_x) / 1000.00
	
	if scale_y == -1:
		sprite_scale.scale.y = sprite_scale.scale.x
	else:
		sprite_scale.scale.y = float(scale_y) / 1000.00

	scale_set.emit(scale_x, scale_y)


func on_rotate(mode: int, value: int) -> void:
	match mode:
		0:
			angle = value
		1:
			if value == 0:
				angle = randi_range(0, 255) << 8
			else:
				angle = randi_range(0, pow(256, 2) - 1) & value
		2:
			angle += value
		3:
			# Depends on object's localid...
			# Unimplemented at this time
			pass
		4:
			angle += randi_range(0, pow(256, 2) - 1) & value
		5:
			# Original code is:
			# rng2 = Random(&RandomSeed);
			# offset->angle = offset->angle + (short)((ulonglong)rng2 % (ulonglong)ip->arg2);
			
			# Random returns a 4-byte int anyway, so the cast to ulonglong
			# probably doesn't do anything. The random number is modulo-ed with
			# the value parameter, then the whole thing is cast to a short, and
			# added to the current angle.
			
			value = max(value, 1)
			angle += (randi_range(0, pow(256, 4) - 1) % value) & 0xFFFF
	
	rotation_degrees = (90.0 / pow(128, 2)) * angle
	rotation_set.emit(rotation_degrees)


func on_draw_normal() -> void:
	scale.x = 1


func on_draw_reverse() -> void:
	scale.x = -1


func on_visual(mode: int, value: int) -> void:
	if ignore_visual:
		return
	
	match mode:
		0:
			visible = bool(value)
		1:
			visual_1 = true
		3:
			material.set_shader_parameter("visual_3", bool(value))
#endregion


func on_palette_changed(for_session: int, pal_index: int) -> void:
	if for_session != owner.session_id:
		return
	
	if not provider.obj_data.has("palettes"):
		return
	
	load_palette(pal_index)
