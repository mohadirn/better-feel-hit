extends StaticBody2D
class_name Dummy

@export var sprite: Node2D

@export_group("Health")
@export var health: int = 5
@export var health_bar: ProgressBar
@export var health_bar_speed: float = 0.2

var _current_health: int
var _bar_tween: Tween
var _deactive_health_bar: bool

@export_group("Hit")
@export var hit_force_power: float = 10.0
@export var hit_force_speed: float = 0.1
@export var hit_color := Color.RED
@export var hit_particle: CPUParticles2D

var _force_tween: Tween
var _color_tween: Tween

func _ready() -> void:
	_current_health = health
	
	#Health Bar
	health_bar.max_value = health
	health_bar.value = health
	health_bar.hide()

func damage(power: int = 1, direction: int = 1):
	_current_health = maxi(0, _current_health - power)
	
	_set_health_bar()
	_set_force_power(power * direction)
	_set_color()
	hit_particle.restart()
	
	if _current_health == 0:
		print("Dummy is dead!")

func _set_health_bar():
	if _deactive_health_bar:
		return
	
	#Progress
	health_bar.show()
	if _bar_tween and _bar_tween.is_valid():
		_bar_tween.kill()
		
	_bar_tween = create_tween(). \
		set_trans(Tween.TRANS_EXPO). \
		set_ease(Tween.EASE_IN). \
		set_parallel()
		
	health_bar.scale *= 1.01
	_bar_tween.tween_property(health_bar, "scale", Vector2.ONE, health_bar_speed)
	_bar_tween.tween_property(health_bar, "value", _current_health, health_bar_speed)
	
	#Color
	var health_ratio: float = clampf(float(_current_health) / float(health), 0.0, 1.0)
	var color = lerp(hit_color, Color.WHITE, health_ratio)
	var style_box = health_bar.get_theme_stylebox("fill").duplicate()
	style_box.bg_color = color
	health_bar.add_theme_stylebox_override("fill", style_box)
	
	if _current_health == 0:
		_deactive_health_bar = true

func _set_force_power(power: int):
	if _force_tween and _force_tween.is_valid():
		_force_tween.kill()
		
	_force_tween = create_tween(). \
		set_trans(Tween.TRANS_ELASTIC). \
		set_ease(Tween.EASE_OUT)
		
	sprite.rotation = deg_to_rad(hit_force_power * power)
	_force_tween.tween_property(sprite, "rotation", 0.0, hit_force_speed)

func _set_color():
	if _color_tween and _color_tween.is_valid():
		_color_tween.kill()
		
	_color_tween = create_tween(). \
		set_trans(Tween.TRANS_SINE). \
		set_ease(Tween.EASE_OUT)
		
	sprite.modulate = hit_color
	_color_tween.tween_property(sprite, "modulate", Color.WHITE, hit_force_speed)
