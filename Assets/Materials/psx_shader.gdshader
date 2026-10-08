shader_type canvas_item;

// Captures the screen buffer behind the ColorRect
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

group_uniforms Resolution;
uniform bool enable_pixelation = true;
uniform vec2 target_resolution = vec2(320.0, 240.0); // Classic PSX resolution

group_uniforms ColorDepth;
uniform bool enable_color_banding = true;
uniform float color_depth : hint_range(1.0, 256.0) = 32.0; // Lower numbers = more retro banding

group_uniforms Dithering;
uniform bool enable_dithering = true;
uniform float dither_intensity : hint_range(0.0, 1.0) = 0.15;

// Bayer Matrix (4x4) for ordered hardware dithering
const mat4 bayer_matrix = mat4(
    vec4(0.0000, 0.5000, 0.1250, 0.6250),
    vec4(0.7500, 0.2500, 0.8750, 0.3750),
    vec4(0.1875, 0.6875, 0.0625, 0.5625),
    vec4(0.9375, 0.4375, 0.8125, 0.3125)
);

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // 1. Pixelation / Low-Res Downscaling
    if (enable_pixelation) {
        uv = floor(uv * target_resolution) / target_resolution;
    }
    
    // Sample the screen color
    vec3 screen_color = texture(screen_texture, uv).rgb;
    
    // 2. 4x4 Ordered Dithering
    if (enable_dithering) {
        // Calculate grid coordinates based on screen pixels
        ivec2 dither_coord = ivec2(FRAGCOORD.xy);
        if (enable_pixelation) {
            dither_coord = ivec2(uv * target_resolution);
        }
        
        // Extract matrix value
        float dither_value = bayer_matrix[dither_coord.x % 4][dither_coord.y % 4] - 0.5;
        
        // Apply dither offset to color channels
        screen_color += dither_value * dither_intensity;
    }
    
    // 3. Color Depth Reduction (15-bit color banding feel)
    if (enable_color_banding) {
        screen_color = floor(screen_color * color_depth) / color_depth;
    }
    
    COLOR = vec4(screen_color, 1.0);
}
