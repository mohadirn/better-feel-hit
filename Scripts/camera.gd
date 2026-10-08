extends Camera2D
class_name ImpactCamera

@export var max_offset: Vector2 = Vector2(100.0, 70.0)
@export var max_roll_degrees: float = 15
@export var decay_rate: float = 3.5

var _noise := FastNoiseLite.new()
var _noise_y: float = 0.0
var _trauma: float = 0.0

func _ready() -> void:
	randomize()
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_noise.frequency = 0.5

func _process(delta: float) -> void:
	if _trauma > 0.0:
		_trauma = maxf(0.0, _trauma - decay_rate * delta)
		_apply_shake(delta)
	else:
		offset = Vector2.ZERO
		rotation = 0.0

func add_trauma(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)

func _apply_shake(delta: float) -> void:
	_noise_y += delta * 60.0
	
	var shake_power := _trauma * _trauma
	
	var shake_x := max_offset.x * shake_power * _noise.get_noise_2d(0.0, _noise_y)
	var shake_y := max_offset.y * shake_power * _noise.get_noise_2d(100.0, _noise_y)
	offset = Vector2(shake_x, shake_y)
	rotation = deg_to_rad(max_roll_degrees * shake_power * _noise.get_noise_2d(200.0, _noise_y))
