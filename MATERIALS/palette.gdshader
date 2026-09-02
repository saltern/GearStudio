// Gear Studio palette shader

shader_type canvas_item;
#pragma disable_preprocessor

uniform bool opaque_bg = false;
uniform bool alpha_double = true;
uniform int hover_index = -1;
uniform int selecting_min = -1;
uniform int selecting_max = -1;
uniform int[0x400]	palette;

void fragment() {
	int index = int(COLOR.r * 256.00);
	index = min(index, 255);

	float alpha = float(palette[4 * index + 3]) / 255.00;

	if (alpha_double) {
		alpha = min(alpha * 2.0, 1.0);
	}

	if (index == 0 && opaque_bg) {
		alpha = 1.0;
	}

	vec4 pal_color = vec4(
		float(palette[4 * index + 0]) / 255.00,
		float(palette[4 * index + 1]) / 255.00,
		float(palette[4 * index + 2]) / 255.00,
		alpha);

	COLOR = pal_color;

	if (index == hover_index) {
		lowp float blend = abs(sin(TIME * 5.0));
		COLOR = mix(vec4(0.0, 0.0, 0.0, 1.0), vec4(0.0, 1.0, 1.0, 1.0), blend);
	}

	if (index >= selecting_min && index <= selecting_max) {
		lowp float blend = abs(sin(TIME * 5.0));
		COLOR = mix(vec4(0.0, 0.0, 0.0, 1.0), vec4(1.0), blend);
	}
}