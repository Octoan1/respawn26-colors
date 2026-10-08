shader_type spatial;
render_mode unshaded;

void vertex() {
	VERTEX.z += cos(TIME * 2.0 + VERTEX.x * 40.0) * .005;
	VERTEX.y += cos(TIME * 2.0 + VERTEX.z * 40.0) * .005;
	VERTEX.z += 0.0;
	//VERTEX.x += sin(TIME * 2.0 + VERTEX.y * 10.0) * .005;
	//VERTEX. += sin(TIME * 1.0 + cos(VERTEX.y)) * .05;

	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
