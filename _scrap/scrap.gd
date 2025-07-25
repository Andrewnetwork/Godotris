
	#var img2 = Image.create(n_cols*cell_size.x,n_rows*cell_size.y,false, Image.FORMAT_RGBA8)
	#img2.fill(Color.RED)
	## Create a sprite and texture it with the above image. 
	#var sprite2 = Sprite2D.new()
	#
	#sprite2.material = ShaderMaterial.new()
	#sprite2.material.shader = load("res://Shaders/tetrino_cell.gdshader")
	#sprite2.texture = ImageTexture.create_from_image(img2)
	#sprite2.position = bounding_box_shape.position
	#bounding_box.add_child(sprite2)

#
#extends Node
#var merged = Geometry2D.merge_polygons(collision_shapes[0, collision_shapes[1])
				#var shape = CollisionPolygon2D.new()
				#shape.polygon = merged[0]
				#var space_state = get_world_2d().direct_space_state
				#var transform = Transform2D(rotation, global_position)
				#var result = space_state.intersect_shape(shape, transform)
				#if result.size() > 0:
					#print("Collision detected during rotation")
