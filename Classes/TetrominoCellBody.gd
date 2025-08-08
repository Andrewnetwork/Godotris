class_name TetrominoCellBody
extends RigidBody2D

var grid : Grid

func  _init(game_grid : Grid):
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = INF
	mass = 10000
	lock_rotation = true
	grid = game_grid

func _physics_process(_delta: float):
	# Snap to the grid at the end of the frame.
	await get_tree().physics_frame
	position = floor(position/grid.cell_size)*grid.cell_size
