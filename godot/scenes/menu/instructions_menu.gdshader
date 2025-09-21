shader_type canvas_item;

void fragment() {
	vec4 sum = vec4(0.0);
	vec2 offset = SCREEN_PIXEL_SIZE * 9.0;

	sum += texture(TEXTURE, UV);
	sum += texture(TEXTURE, UV + vec2(offset.x, 0.0));
	sum += texture(TEXTURE, UV - vec2(offset.x, 0.0));
	sum += texture(TEXTURE, UV + vec2(0.0, offset.y));
	sum += texture(TEXTURE, UV - vec2(0.0, offset.y));

	COLOR = sum / 5.0;
	COLOR *= 0.6;
	COLOR.a = 255.0/2.0;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
