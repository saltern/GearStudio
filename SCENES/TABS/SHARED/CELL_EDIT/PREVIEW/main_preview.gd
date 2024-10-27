extends ZoomablePreview

@export var box_parent: Control
@export var origin_point: Control
@export var user_guide_h: ColorRect
@export var user_guide_v: ColorRect
@export var user_guides: Control

enum GuideMode {
	NONE,
	HORIZONTAL,
	VERTICAL,
	BOTH,
	MAX,
}

var sprite_drag: bool = false
var tentative: bool = false
var guide_mode: GuideMode = GuideMode.NONE

@onready var cell_edit: CellEdit = get_owner()


func mouse_button(event: InputEventMouseButton) -> void:
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			if event.pressed:
				if guide_mode != GuideMode.NONE:
					guide_place()
				
				elif cell_edit.box_drawing_mode:
					box_parent.start_drawing(
						event.position - visualizer.position)
				
				elif event.alt_pressed:
					guide_mode = GuideMode.NONE
					sprite_drag = true
				
				else:
					tentative = true
			
			else:
				if sprite_drag:
					sprite_drag = false
					accum = Vector2.ZERO
				
				elif tentative:
					cell_edit.box_deselect_all()
					tentative = false
				
				box_parent.stop_drawing(
					event.position - visualizer.position, true)


func mouse_motion(event: InputEventMouseMotion) -> void:
	user_guide_h.position = origin_point.get_local_mouse_position()
	user_guide_h.position -= Vector2(3000, 1)
	user_guide_v.position = origin_point.get_local_mouse_position()
	user_guide_v.position -= Vector2(1, 3000)

	if sprite_drag:
		var mov_scale: float = visualizer.scale.x
		var scaled_relative: Vector2 = event.relative / mov_scale
		accum += scaled_relative
		var accum_floor := Vector2(floor(accum.x), floor(accum.y))
		
		cell_edit.sprite_set_position(
			cell_edit.this_cell.sprite_info.position +
			(accum_floor as Vector2i))
		
		accum -= accum_floor
	
	box_parent.drag(event.position - visualizer.position)


func keyboard(event: InputEventKey) -> void:
	match event.keycode:
		KEY_G:
			guide_cycle_mode()
		KEY_H:
			guide_remove_all()
		KEY_ESCAPE:
			guide_mode = GuideMode.NONE
			

func guide_cycle_mode() -> void:
	guide_mode = wrapi(guide_mode + 1, 0, GuideMode.MAX) as GuideMode
	cell_edit.box_set_draw_mode(false)
	
	user_guide_h.hide()
	user_guide_v.hide()
	Status.set_status("Guide placement mode: disabled.")
	
	match guide_mode:
		GuideMode.HORIZONTAL:
			user_guide_h.show()
			Status.set_status("Guide placement mode: horizontal line.")
			
		GuideMode.VERTICAL:
			user_guide_v.show()
			Status.set_status("Guide placement mode: vertical line.")

		GuideMode.BOTH:
			user_guide_h.show()
			user_guide_v.show()
			Status.set_status("Guide placement mode: cross.")


func guide_place() -> void:
	if guide_mode % 2 == 1:
		var new_guide_h: ColorRect = user_guide_h.duplicate()
		user_guides.add_child(new_guide_h)
		new_guide_h.visible = true
	
	if guide_mode > 1:
		var new_guide_v: ColorRect = user_guide_v.duplicate()
		user_guides.add_child(new_guide_v)
		new_guide_v.visible = true


func guide_remove_all() -> void:
	user_guides.clear_guides()
	Status.set_status("All guides removed.")
