extends Area2D
class_name Weapon

signal hit(body: Node2D)

@export var power: int = 1

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	deactivate()

func activate() -> void:
	set_deferred("monitoring", true)
	show()

func deactivate() -> void:
	set_deferred("monitoring", false)
	hide()

func _on_area_entered(body: Node2D) -> void:
	hit.emit(body)
	if body.get_parent().has_method("damage"):
		var dir = global_position.direction_to(body.global_position).normalized().x
		body.get_parent().damage(power, 1 if dir > 0 else -1)
		
		#Camera Impact Shake
		var cam := get_viewport().get_camera_2d()
		if cam and cam.has_method("add_trauma"):
			cam.add_trauma(0.4)
		
		#Background
		Global.background.set_color()
