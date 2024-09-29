// Gear Studio palette shader

shader_type canvas_item;
#pragma disable_preprocessor

uniform bool alpha_double = true;
uniform bool reindex = true;
uniform int hover_index = -1;
uniform bool[256] highlight;
uniform int[0x400]	palette;


void fragment() {
	int index = int(COLOR.r * 255.00);
	
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

	vec4 pal_color = vec4(
		float(palette[4 * index + 0]) / 255.00,
		float(palette[4 * index + 1]) / 255.00,
		float(palette[4 * index + 2]) / 255.00,
		alpha);

	lowp float blend = 0.0;

	COLOR = pal_color;

	if (highlight[index]) {
		blend = abs(sin(TIME * 5.0));
		COLOR = mix(vec4(0.0, 0.0, 0.0, 1.0), vec4(1.0), blend);
	}

	if (index == hover_index) {
		blend = abs(sin(TIME * 5.0));
		COLOR = mix(vec4(0.0, 0.0, 0.0, 1.0), vec4(0.0, 1.0, 1.0, 1.0), blend);
	}
}