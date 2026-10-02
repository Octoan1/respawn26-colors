shader_type spatial;

// Force a perfect 0.5m square metric grid
const float SQUARE_SIZE = 0.5;

varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
    // 1. Capture the true 3D absolute world position of every vertex
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // 2. Capture the world direction of the faces so the shader knows where the 'top' is
    world_normal = abs(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
    // Normalize the normal weights so they add up cleanly to 1.0
    vec3 blend_weights = world_normal / (world_normal.x + world_normal.y + world_normal.z);
    
    // Divide the true world position by our 0.5 meter metric constraint
    vec3 grid = floor(world_pos / SQUARE_SIZE);
    
    // 3. Project flat 2D grids independently across the 3 spatial axes
    float check_x = mod(grid.y + grid.z, 2.0); // Side projection
    float check_y = mod(grid.x + grid.z, 2.0); // TOP projection (The Cylinder Cap!)
    float check_z = mod(grid.x + grid.y, 2.0); // Front projection

    // 4. Blend the 3 perspectives perfectly based on face direction
    float pattern = (check_x * blend_weights.x) + 
                    (check_y * blend_weights.y) + 
                    (check_z * blend_weights.z);
                    
    // 5. Sharpen the edge blend so the checkerboard transition isn't blurry on curved mesh walls
    pattern = step(0.5, pattern);
    
    // Apply final colors
    ALBEDO = mix(vec3(0.4), vec3(0.6), pattern);
}