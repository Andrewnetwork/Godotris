extends Node2D

var current_tetromino : Tetromino = null

func _ready():
	pass

func _process(delta: float):
	#var local_mouse_pos = get_local_mouse_position()
	#if current_tetromino == null:
		#current_tetromino = Tetromino.new(Tetromino.TetrominoType.values()[randi_range(0,6)])
		#add_child(current_tetromino)
	#
	#current_tetromino.position = $"Rocket/Thruster".position

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var local_mouse_pos = get_local_mouse_position()
		var nt = Tetromino.new(Tetromino.TetrominoType.values()[randi_range(0,6)])
		nt.position = local_mouse_pos
		add_child(nt)
		
	if Input.is_key_pressed(KEY_SPACE):
		var nt = Tetromino.new(Tetromino.TetrominoType.values()[randi_range(0,6)])
		nt.position = $"Rocket".position
		nt.size = Vector2(50,50)
		nt.position.y += 200
		add_child(nt)
	
	##$Trampoline.apply_central_impulse(Vector2(0,100.0))
