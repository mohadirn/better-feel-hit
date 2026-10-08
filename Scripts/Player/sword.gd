extends Weapon
class_name Sword

@export var animation_player: AnimationPlayer

const HIT := "hit"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hit"):
		animation_player.stop()
		animation_player.play(HIT)
