shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float hit_intensity : hint_range(0, 1) = 0.0;
uniform float hit_time : hint_range(0, 10) = 0.0;

void fragment() {
    vec4 screen_color = texture(SCREEN_TEXTURE, UV);
    vec3 color = screen_color.rgb;
    
    vec2 center = UV - 0.5;
    float distance_from_center = length(center);
    
    float border_mask = smoothstep(0.3, 0.7, distance_from_center);
    
    float pulse = sin(hit_time * 10.0) * 0.5 + 0.5;
    float dynamic_intensity = hit_intensity * pulse;
    
    vec3 blood_red = vec3(0.8, 0.1, 0.1);
    float red_strength = border_mask * dynamic_intensity;
    
    color = mix(color, blood_red, red_strength);
    
    color *= (1.0 - border_mask * dynamic_intensity * 0.3);
    
    if (hit_intensity > 0.5) {
        vec2 blur_dir = normalize(center) * 0.01 * hit_intensity;
        vec3 blurred = texture(SCREEN_TEXTURE, UV + blur_dir).rgb;
        color = mix(color, blurred, border_mask * hit_intensity * 0.4);
    }

    COLOR = vec4(color, screen_color.a);
}