// Gear Studio palette shader (no highlights)
shader_type canvas_item;
#pragma disable_preprocessor

uniform int[0x400]	palette;


void fragment()
{
	int index = int(COLOR.r * 256.00);

	vec4 pal_color = vec4(
		float(palette[4 * index + 0]) / 256.00,
		float(palette[4 * index + 1]) / 256.00,
		float(palette[4 * index + 2]) / 256.00,
		float(palette[4 * index + 3]) / 256.00);

	COLOR = pal_color;
}