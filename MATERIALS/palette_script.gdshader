// Gear Studio palette shader

shader_type canvas_item;
#pragma disable_preprocessor

uniform int blend_mode = 0;
uniform int blend_value = 0x100;
uniform bool alpha_double = true;
uniform bool reindex = true;
uniform bool visual_3 = false;
uniform int[0x400]	palette;

uniform sampler2D screen_tex: hint_screen_texture, filter_nearest;


void fragment() {
	vec4 SCREEN_TEXTURE = texture(screen_tex, SCREEN_UV);

	int index = int(COLOR.r * 256.00);
	index = clamp(index, 0, 255);

	if (reindex) {
		if (((index / 8) + 2) % 4 == 0) {
			index -= 8;
		}

		else if (((index / 8) + 3) % 4 == 0) {
			index += 8;
		}
	}

	float alpha = float(palette[4 * index + 3]) / 255.00;

	if (alpha_double) {
		alpha = min(alpha * 2.0, 1.0);
	}
	
	int r = palette[4 * index + 0];
	int g = palette[4 * index + 1];
	int b = palette[4 * index + 2];
	
	// VISUAL 3 1
	if (visual_3) {
		r = min(r + 0xC0, 0xFF);
		g = min(g + 0xC0, 0xFF);
		b = min(b + 0xC0, 0xFF);
	}
	
	vec4 pal_color = vec4(
		float(r) / 255.00,
		float(g) / 255.00,
		float(b) / 255.00,
		alpha);
	
	float blended_alpha = (float(blend_value) * pal_color.a) / 255.00;
	
	if (blend_mode == 1) {
		COLOR = mix(SCREEN_TEXTURE, SCREEN_TEXTURE + pal_color, blended_alpha);
	}

	else {
		COLOR = vec4(pal_color.rgb, pal_color.a * float(blend_value) / 255.0);
	}
}