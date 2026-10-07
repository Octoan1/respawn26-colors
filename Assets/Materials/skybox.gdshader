shader_type sky; 

uniform vec3 sky_color : source_color = vec3(0.109, 0.109, 0.109); // uses the agreed upon black color

void sky() {
    COLOR = sky_color;
}
