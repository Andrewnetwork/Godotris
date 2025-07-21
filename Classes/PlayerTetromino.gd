class_name PlayerTetromino
extends Node2D

enum MoveType {DOWN, LEFT, RIGHT, STILL}

var tetromino: Tetromino
var move_flag : MoveType = MoveType.STILL
var is_frozen = false

func _init(size: Vector2):
	tetromino = Tetromino.new()
	add_child(tetromino)
		
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_left"):
		move(MoveType.LEFT)
	elif event.is_action_pressed("ui_right"):
		move(MoveType.RIGHT)
	elif event.is_action_pressed("ui_down"):
		move(MoveType.DOWN)

func move(move_type: MoveType):
	move_flag = move_type

func _physics_process(delta: float):
	if !is_frozen:
		match move_flag:
			MoveType.STILL:
				pass
			MoveType.DOWN:
				if tetromino.move_and_collide(Vector2(0, tetromino.size.y)) != null:
					is_frozen = true
			MoveType.LEFT:
				if tetromino.move_and_collide(Vector2(-tetromino.size.x, 0)) != null:
					#is_frozen = true
					pass
			MoveType.RIGHT:
				if tetromino.move_and_collide(Vector2(tetromino.size.x, 0)) != null:
					#is_frozen = true
					pass
		move_flag = MoveType.STILL	 
