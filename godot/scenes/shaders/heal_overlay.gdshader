shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float heal_intensity : hint_range(0, 1) = 0.0;
uniform float heal_time : hint_range(0, 10) = 0.0;

void fragment() {
    vec4 screen_color = texture(SCREEN_TEXTURE, UV);
    vec3 color = screen_color.rgb;
    
    vec2 center = UV - 0.5;
    float distance_from_center = length(center);
    
    float corner_mask = smoothstep(0.3, 0.7, distance_from_center);
    
    float pulse = sin(heal_time * 6.0) * 0.2 + 0.8;
    float dynamic_intensity = heal_intensity * pulse;
    

    vec3 heal_color = vec3(0.25, 0.8, 0.4);
    float heal_strength = corner_mask * dynamic_intensity * 0.7;
    

    color = mix(color, heal_color, heal_strength);

    color *= (1.0 + corner_mask * dynamic_intensity * 0.15);
    
    if (heal_intensity > 0.3) {
        float glow = smoothstep(0.3, 0.7, distance_from_center) * dynamic_intensity * 0.3;
        vec3 glow_color = vec3(0.4, 0.7, 0.6);
        color = mix(color, glow_color, glow);
    }
    
    if (heal_intensity > 0.5) {
        vec2 blur_dir = normalize(center) * 0.003 * heal_intensity;
        vec3 blurred = texture(SCREEN_TEXTURE, UV + blur_dir).rgb;
        color = mix(color, blurred, corner_mask * heal_intensity * 0.2);
    }

    COLOR = vec4(color, screen_color.a);
}