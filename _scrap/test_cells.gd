extends Node2D

var nc : TetrominoCell
var rigid : RigidBody2D

func spawn_tetromino_cell(pos: Vector2):
	var cell = TetrominoCell.new(Color.RED, Vector2(100,100), Vector2.ZERO, 0)
	var rb = RigidBody2D.new()
	rb.add_child(cell)
	rb.position = pos
	rb.freeze = true
	rb.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	add_child(rb)
	return rb
func _ready() -> void:
	#rigid = spawn_tetromino_cell(Vector2(150,630))
	pass

func _physics_process(delta: float):
	#rigid.position.y += 1
	#sb.constant_linear_velocity = Vector2.ONE * 10
	var mouse_pos = get_viewport().get_mouse_position()

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		spawn_tetromino_cell(mouse_pos)
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("HEY")
