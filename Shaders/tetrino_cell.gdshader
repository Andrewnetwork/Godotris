shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	if(UV.x > 0.9 && UV.x-UV.y > 0.0 && UV.y+UV.x > 1.0){
		// Right
		COLOR.rgb -= 0.4;
	}else if(UV.x < 0.1 && UV.x-UV.y < 0.0 && UV.y+UV.x < 1.0){
		// Left
		COLOR.rgb -= 0.2;
	}else if(UV.y < 0.1){
		// Top
		COLOR.rgb -= 0.6;
	}else if(UV.y > 0.9){
		// Bottom
		COLOR.rgb -= 0.4;
	}else{
		//COLOR.rgb += sin(TIME*2.0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
