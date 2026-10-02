shader_type spatial;

void fragment() {
    // Scale the UV coordinates to determine the size of the checkers
    vec2 grid = floor(UV * 10.0); 
    // Alternate colors based on the grid math
    float pattern = mod(grid.x + grid.y, 2.0);
    // Mix two colors (e.g., light gray and dark gray)
    ALBEDO = mix(vec3(0.4), vec3(0.6), pattern);
}