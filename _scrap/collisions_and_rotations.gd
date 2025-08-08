extends Node2D

var time = 0

func _physics_process(delta: float):
	time += delta
	if Input.is_action_pressed("ui_down"):
		#$RigidBody2D.apply_impulse(Vector2(0,300))
		$Area2D.position.y += 10
		print(time)
	if Input.is_action_pressed("ui_up"):
		#$RigidBody2D.apply_impulse(Vector2(0,-300))
		$Area2D.position.y -= 10
		print(time)
	if Input.is_action_pressed("ui_left"):
		#$RigidBody2D.apply_impulse(Vector2(-300,0))
		$Area2D.position.x -= 10
		print(time)
	if Input.is_action_pressed("ui_right"):
		#$RigidBody2D.apply_impulse(Vector2(300,0))
		$Area2D.position.x += 10
		print(time)
	if Input.is_action_just_pressed("immediate_drop"):
		#$RigidBody2D.apply_torque(3000000)
		pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Body entered")
