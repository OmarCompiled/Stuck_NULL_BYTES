shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float sanity_intensity : hint_range(0, 1) = 0.0;
uniform float time : hint_range(0, 100) = 0.0;
uniform float death_fade : hint_range(0, 1) = 0.0;
uniform float win_fade : hint_range(0, 1) = 0.0;
uniform float vignette_start : hint_range(0, 1) = 0.4;
uniform float vignette_end : hint_range(0, 1) = 0.8;

void fragment() {
    vec2 base_uv = UV;
    vec4 screen_color = texture(SCREEN_TEXTURE, base_uv);
    vec3 color = screen_color.rgb;

    // Fisheye lens warp
    vec2 center_vec = base_uv - 0.5;
    float dist = length(center_vec);
    float bubble_warp = pow(dist, 1.5) * 0.4 * sanity_intensity;
    vec2 warped_uv = base_uv + center_vec * bubble_warp;
    vec3 warped_color = texture(SCREEN_TEXTURE, warped_uv).rgb;
    color = mix(color, warped_color, sanity_intensity);

    // Vignette
    float vignette = 1.0 - smoothstep(vignette_start, vignette_end, dist) * (0.6 + sanity_intensity * 0.4);
    color *= vignette;

    // Shift toward sickly yellow-green and deep crimson
    vec3 nightmare_tint = mix(vec3(1.0), vec3(0.75, 0.3, 0.15), sanity_intensity * 0.75);
    color *= nightmare_tint;

    // Boost red channel
    color.r *= (1.0 + sanity_intensity * 0.7);

    color = (color - 0.5) * (1.0 + sanity_intensity * 0.025) + 0.5;

    color = mix(color, vec3(0.0), death_fade);
    color = mix(color, vec3(0.5), win_fade);

    COLOR = vec4(color, screen_color.a);
}