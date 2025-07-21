@tool
class_name Grid2D
extends Node2D

@export var cell_size: Vector2 = Vector2(25, 25)
@export var grid_size: Vector2 = Vector2(20, 15)
@export var grid_color: Color = Color(0.5, 0.5, 0.5)
@export var background_color : Color = Color(1.0,1.0,1.0,0.0)
var grid_items : Array[Node2D]

func add_item(grid_item: Node2D, center_cell: Vector2):
	grid_item.position = Vector2(center_cell.y*cell_size.y-cell_size.y/2.0, center_cell.x*cell_size.x+cell_size.x/2.0)
	grid_items.append(grid_item)
	add_child(grid_item)
func move_item(grid_item: Node2D, new_center_cell: Vector2):
	grid_item.position = Vector2(new_center_cell.y*cell_size.y-cell_size.y/2.0, new_center_cell.x*cell_size.x+cell_size.x/2.0)
func _draw():
	# Background
	draw_rect(Rect2(Vector2(0.0, 0.0), 
		Vector2(cell_size.x * grid_size.x, cell_size.y * grid_size.y) ),
			background_color)
			
	# Vertical lines
	for x in range(grid_size.x + 1):
		var start = Vector2(x * cell_size.x, 0)
		var end = Vector2(x * cell_size.x, grid_size.y * cell_size.y)
		draw_line(start, end, grid_color)

	# Horizontal lines
	for y in range(grid_size.y + 1):
		var start = Vector2(0.0, y * cell_size.y)
		var end = Vector2(grid_size.x * cell_size.x, y * cell_size.y)
		draw_line(start, end, grid_color)
