extends Control

var draw_bounds: bool = true
var bounds: Rect2i

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	sprite_edit.sprite_updated.connect(on_sprite_updated)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(bounds, Settings.sprite_color_bounds, true)


func update_mode(new_value: bool) -> void:
	visible = new_value


func on_sprite_updated(sprite: BinSprite) -> void:
	bounds = Rect2i(Vector2i.ZERO, sprite.texture.get_size())
