shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float sanity_intensity : hint_range(0, 1) = 0.0;
uniform float time : hint_range(0, 100) = 0.0;

void fragment() {
    vec2 base_uv = UV;
    vec4 screen_color = texture(SCREEN_TEXTURE, base_uv);
    vec3 color = screen_color.rgb;

    // 1. Fisheye lens warp
    vec2 center_vec = base_uv - 0.5;
    float dist = length(center_vec);
    float bubble_warp = pow(dist, 1.5) * 0.25 * sanity_intensity;
    vec2 warped_uv = base_uv + center_vec * bubble_warp;
    vec3 warped_color = texture(SCREEN_TEXTURE, warped_uv).rgb;
    color = mix(color, warped_color, sanity_intensity);

    // 2. Dark vignette
    float vignette = 1.0 - (dot(center_vec, center_vec) * sanity_intensity);
    vignette = pow(vignette, 2.0); // Make the falloff sharper
    color *= vignette;

    // 3. Pulsing distortions
    float vein_time = time * 0.5;
    float vein_pattern = sin(base_uv.x * 50.0 + vein_time) * sin(base_uv.y * 30.0 + vein_time);
    vec2 vein_offset = vec2(vein_pattern * 0.005 * sanity_intensity);
    vec3 vein_color = texture(SCREEN_TEXTURE, warped_uv + vein_offset).rgb;
    color = mix(color, vein_color, smoothstep(0.3, 0.7, sanity_intensity));

    // 4. Color distortion
    // Shift toward sickly yellow-green and deep crimson
    vec3 nightmare_tint = mix(vec3(1.0), vec3(0.75, 0.3, 0.15), sanity_intensity * 0.75);
    color *= nightmare_tint;

    // Boost red channel
    color.r *= (1.0 + sanity_intensity * 0.7);

    COLOR = vec4(color, screen_color.a);
}