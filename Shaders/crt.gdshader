shader_type canvas_item;

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
void vertex() {
	// Called for every vertex the material is visible on.
}
void fragment() {
	// Called for every pixel the material is visible on.
	//COLOR = vec4(draw_function2(UV),0,0,1);
	float noise = rand(UV+TIME);
	COLOR.r += sin(UV.x*300.0)/20.0;
	COLOR.g += sin(UV.y*300.0+TIME*50.0)/20.0;
	COLOR.a -= noise/6.0;
}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
