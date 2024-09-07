extends SpinBox

@export var include_toggle: CheckButton
@export var override_toggle: CheckButton
@export var alpha_mode_menu: OptionButton
@export var reindex_toggle: CheckButton
@export var palette_material: ShaderMaterial
@export var sprite_index: SpinBox

enum AlphaMode {
	AS_IS,
	DOUBLE,
	HALVE,
	OPAQUE,
}

var include: bool = false
var override: bool = false
var alpha_mode: AlphaMode = AlphaMode.AS_IS
var reindex: bool
var pal_gray: PackedByteArray = []
var pal_current: PackedByteArray

@onready var obj_state := SessionData.object_state_get(
	get_owner().get_parent().name)

@onready var pal_state := SessionData.palette_state_get(
	get_owner().get_parent().get_parent().get_index())


func _ready() -> void:
	for i in 256:
		# RGBA
		pal_gray.append(i)
		pal_gray.append(i)
		pal_gray.append(i)
		pal_gray.append(255)
	
	sprite_index.value_changed.connect(on_sprite_index_changed)
	
	include_toggle.toggled.connect(on_include_toggled)
	
	override = override_toggle.button_pressed
	override_toggle.toggled.connect(on_override_toggled)
	
	alpha_mode_menu.item_selected.connect(on_alpha_mode_changed)
	
	reindex_toggle.toggled.connect(on_reindex_toggled)
	
	value_changed.connect(on_palette_index_changed)
	on_override_toggled(override_toggle.button_pressed)


func on_sprite_index_changed(_new_index: int) -> void:
	on_palette_index_changed(value)


func on_include_toggled(enabled: bool) -> void:
	include = enabled
	on_palette_index_changed(value)


func on_override_toggled(enabled: bool) -> void:
	override = enabled
	on_palette_index_changed(value)


func on_alpha_mode_changed(new_mode: int) -> void:
	alpha_mode = new_mode as AlphaMode
	on_palette_index_changed(value)


func on_reindex_toggled(enabled: bool) -> void:
	reindex = enabled
	on_palette_index_changed(value)


func on_palette_index_changed(new_index: int) -> void:
	SpriteExport.palette_index = new_index
	
	var use_pal_state_pal: bool = false
	var this_sprite := obj_state.sprite_get(sprite_index.value)
	
	if get_owner().get_parent().name == "player":
		if override:
			use_pal_state_pal = true
		
		if this_sprite.palette.is_empty():
			use_pal_state_pal = true
	
	if not include:
		pal_current = pal_gray
	
	elif use_pal_state_pal:
		pal_current = pal_state.get_palette_colors(new_index)
		pal_current = process_reindex(pal_current)
		pal_current = process_alpha(pal_current)
	
	elif not this_sprite.palette.is_empty():
		pal_current = this_sprite.palette
		pal_current = process_reindex(pal_current)
		pal_current = process_alpha(pal_current)
		
	else:
		pal_current = pal_gray

	
	palette_material.set_shader_parameter(
		"palette", pal_current)


func process_reindex(palette: PackedByteArray) -> PackedByteArray:
	if not reindex:
		return palette
	
	if obj_state.sprite_get(sprite_index.value).bit_depth == 4:
		return palette
	
	var temp_pal: PackedByteArray = []
	temp_pal.resize(1024)
	
	for index in palette.size() / 4:
		var r_index: int = index
		
		if ((r_index / 8) + 2) % 4 == 0:
			r_index -= 8
		
		elif ((r_index / 8) + 3) % 4 == 0:
			r_index += 8
		
		temp_pal[4 * r_index + 0] = palette[4 * index + 0]
		temp_pal[4 * r_index + 1] = palette[4 * index + 1]
		temp_pal[4 * r_index + 2] = palette[4 * index + 2]
		temp_pal[4 * r_index + 3] = palette[4 * index + 3]
	
	return temp_pal


func process_alpha(palette: PackedByteArray) -> PackedByteArray:
	for index in palette.size() / 4:
		var this_index: int = 4 * index + 3
		var this_alpha: int = palette[this_index]
		
		match alpha_mode:
			AlphaMode.DOUBLE:
				palette[this_index] = min(this_alpha * 2, 0xFF)
			
			AlphaMode.HALVE:
				palette[this_index] = this_alpha / 2
			
			AlphaMode.OPAQUE:
				palette[this_index] = 0xFF
	
	return palette
