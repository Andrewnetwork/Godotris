extends Node2D
@export var width = 10 : set = _on_width_changed 
@export var height = 10 : set = _on_height_changed 

func _ready():
	fade_cycle()
	

func _process(delta):
	pass

func fade_cycle():
	render_grid()
	fade_out(0.2,5)

func fade_out(min_duration = 1, max_duration = 1):
	for child in get_children():
		if child is RandomColorSquare:
			child.fade_out(min_duration+randf()*max_duration)
			
func render_grid():
	# Render grid
	for y in range(height):
		for x in range(width):
			add_child(RandomColorSquare.new(x*10,y*10, 10, 10))
			
func _on_width_changed(value):
	width = value
	render_grid()
func _on_height_changed(value):
	height = value
	render_grid()
	
