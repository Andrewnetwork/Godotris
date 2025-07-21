extends Node2D
var timer = 0
var player_tetromino = PlayerTetromino.new(Vector2(25,25))
	
	
func move_player_tetromino():
	if !player_tetromino.is_frozen:
		pass

func _ready():
	$Grid2D.add_item(player_tetromino, Vector2(0,8))
	
	var static_tetromino = Tetromino.new(Vector2(25,25))
	$Grid2D.add_item(static_tetromino, Vector2(10,8))

func _process(delta: float):
	timer += delta
	
	if int(ceil(timer)) % 2 == 0:
		timer = 0
		if !player_tetromino.is_frozen:
			player_tetromino.move(PlayerTetromino.MoveType.DOWN)
		else:
			player_tetromino = PlayerTetromino.new(Vector2(25,25))
			$Grid2D.add_item(player_tetromino, Vector2(0,8))
			
		
	
