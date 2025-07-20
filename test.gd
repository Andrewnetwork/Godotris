extends Node2D

func _ready():
	pass

func _process(delta: float):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var local_mouse_pos = get_local_mouse_position()
		var nt = Tetromino.new()
		nt.type = Tetromino.TetrominoType.values()[randi_range(0,6)]
		nt.position = local_mouse_pos
		add_child(nt)
