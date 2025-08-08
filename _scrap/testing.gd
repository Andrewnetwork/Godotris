extends Node2D

func _ready():
	pass
func _physics_process(delta: float):
	$P2.move_and_collide($P1.position-Vector2(0,500))
