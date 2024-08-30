// Gear Studio palette shader

shader_type canvas_item;
#pragma disable_preprocessor

uniform int highlight_index = -1;
uniform bool[256] highlight;
uniform int[0x400]	palette;


void fragment()
{
	int index = int(COLOR.r * 256.00);
	
	vec4 pal_color = vec4(
		float(palette[4 * index + 0]) / 256.00,
		float(palette[4 * index + 1]) / 256.00,
		float(palette[4 * index + 2]) / 256.00,
		float(palette[4 * index + 3]) / 256.00);
	
	float blend = 0.0;
	
	if (highlight[index]) {
		blend = abs(sin(TIME * 5.0));
		COLOR = mix(vec4(0.0, 0.0, 0.0, 1.0), vec4(1.0), blend);
	}
	
	else {
		COLOR = pal_color;
	}
}