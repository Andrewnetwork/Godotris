extends Node2D
var timer = 0
var player_tetromino = Tetromino.new(Vector2(25,25))
	
func _ready():
	$Grid2D.add_item(player_tetromino, Vector2(0,8))
	
	var static_tetromino = Tetromino.new(Vector2(25,25))
	static_tetromino.is_frozen = true
	$Grid2D.add_item(static_tetromino, Vector2(10,8))

func _process(delta: float):
	timer += delta
		
	if !player_tetromino.is_frozen:
		if int(ceil(timer)) % 2 == 0:
			timer = 0
			player_tetromino.move(Tetromino.MoveType.DOWN)
	else:
		# New piece to move. 
		player_tetromino = Tetromino.new(Vector2(25,25))
		$Grid2D.add_item(player_tetromino, Vector2(0,8))
		
		
	
