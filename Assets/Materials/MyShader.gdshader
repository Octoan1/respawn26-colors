shader_type spatial;
render_mode cull_front;

void vertex() {
	VERTEX.y += sin(TIME * 2.0 + cos(VERTEX.x)) * -1.0;
	VERTEX.x += sin(TIME * 5.0 + sin(VERTEX.y)) * 2.0;

	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
