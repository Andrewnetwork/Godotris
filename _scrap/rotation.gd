extends Node2D

func rotate_sprite_around_pivot(sprite: Node2D, pivot: Vector2, angle_degrees: float):
	var offset = sprite.global_position - pivot
	var rotated_offset = offset.rotated(deg_to_rad(angle_degrees))
	sprite.global_position = pivot + rotated_offset

func _ready():
	$Icon.rotate(deg_to_rad(90))
	rotate_sprite_around_pivot($Second, Vector2(200,200), 90)
	
