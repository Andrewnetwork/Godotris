extends Node2D

var tetromino_manager : TetrominoManager

func _ready():
	tetromino_manager = TetrominoManager.new($Grid2D)
	add_child(tetromino_manager)
