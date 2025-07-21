extends Node2D

func _process(delta: float):
	var local_mouse_pos = get_local_mouse_position()
	var nt = Tetromino.new(Tetromino.TetrominoType.values()[randi_range(0,6)])
	nt.position = Vector2(randi_range(0,500),-200)
	$Container1.add_child(nt)
