shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix( vec3(1.0), rgb, c.y);
}

void fragment() {
	// Called for every pixel the material is visible on.
	if(UV.x > 0.9 && UV.x-UV.y > 0.0 && UV.y+UV.x > 1.0){
		// Right
		COLOR.rgb += 0.4;
	}else if(UV.x < 0.1 && UV.x-UV.y < 0.0 && UV.y+UV.x < 1.0){
		// Left
		COLOR.rgb += 0.4;
		COLOR.a -= 0.2;
	}else if(UV.y < 0.1){
		// Top
		COLOR.rgb += 0.4;
		COLOR.a -= 0.2;
	}else if(UV.y > 0.9){
		// Bottom
		COLOR.rgb += 0.4;
	}else{
		vec3 color = vec3(0.0);
	    // Use polar coordinates instead of cartesian
	    vec2 toCenter = vec2(0.5)-UV;
	    float angle = atan(toCenter.y,toCenter.x)+TIME/2.0;
	    float radius = length(toCenter)*2.0;

	    // Map the angle (-PI to PI) to the Hue (from 0 to 1)
	    // and the Saturation to the radius
		COLOR.rgb -= hsb2rgb(vec3((angle/6.28318530718)+0.5,radius,1.0))/3.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
