extends CanvasLayer
class_name Background

@export var color := Color(1.0, 1.0, 1.0, 0.1)
@export var color_sprite: CanvasItem
@export var color_duration: float = 0.4

var _color_tween: Tween

func _ready() -> void:
	Global.background = self

func set_color():
	if _color_tween and _color_tween.is_valid():
		_color_tween.kill()
		
	_color_tween = create_tween(). \
		set_trans(Tween.TRANS_SINE). \
		set_ease(Tween.EASE_OUT)
		
	color_sprite.modulate = color
	_color_tween.tween_property(color_sprite, "modulate", Color.TRANSPARENT, color_duration)
