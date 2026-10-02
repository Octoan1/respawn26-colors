shader_type spatial;

// Pass local position to the fragment shader
varying vec3 local_pos;

void vertex() {
    // 1. CHANGE: Use raw VERTEX coordinates (Local Space) instead of multiplying by MODEL_MATRIX
    local_pos = VERTEX;
}

void fragment() {
    // 2. CHANGE: Use local_pos instead of world coordinates. 
    // Divide by the desired physical size of the squares (e.g., 0.5 units)
    vec3 grid = floor(local_pos / 1.0); 
    
    // Calculate the 3D alternating pattern
    float pattern = mod(grid.x + grid.y + grid.z, 2.0);
    
    // Mix two colors
    ALBEDO = mix(vec3(0.4), vec3(0.6), pattern);
}