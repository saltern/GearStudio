// Gear Studio palette shader

shader_type canvas_item;
#pragma disable_preprocessor

uniform bool alpha_double = true;
uniform bool as_rgb = false;
uniform bool reindex_pixels = false;
uniform bool reindex_palette = false;

uniform bool is_depth_4 = false;
uniform bool is_depth_8 = false;
uniform bool force_depth_4 = false;
uniform bool force_depth_8 = false;

uniform bool half_clut = false;
uniform int hover_index = -1;
uniform int selecting_min = -1;
uniform int selecting_max = -1;
uniform int[0x400] palette;
uniform int[0x100] palette_as_rgb;


int transform_index(int index) {
	if (is_depth_4 && !force_depth_8) {
		return index;
	}
	
	switch (index & 0x18) {
		case 0x10:	return index -= 8;
		case 0x08:	return index += 8;
		default:	return index;
	}
}


vec4 get_color(int index) {
	if (reindex_palette) {
		index = transform_index(index);
	}
	
	return vec4(
		float(palette[4 * index + 0]) / 255.00,
		float(palette[4 * index + 1]) / 255.00,
		float(palette[4 * index + 2]) / 255.00,
		float(palette[4 * index + 3]) / 255.00
	);
}


// Ugly...
int cap_index(int index) {
	if (force_depth_4) {
		if (half_clut) {
			return min(index, 0x7);
		} else {
			return min(index, 0xF);
		}
	}
	
	else if (force_depth_8) {
		if (half_clut) {
			return min(index, 0x7F);
		}
	}
	
	else if (is_depth_4) {
		if (half_clut) {
			return min(index, 0x7);
		} else {
			return min(index, 0xF);
		}
	}
	
	else if (is_depth_8) {
		if (half_clut) {
			return min(index, 0x7F);
		}
	}
	
	return min(index, 0xFF);
}


void fragment() {
	int index = int(COLOR.r * 256.00);
	
	if (as_rgb) {
		index = palette_as_rgb[index];
	}
	
	if (reindex_pixels) {
		index = transform_index(index);
	}
	
	index = cap_index(index);
	vec4 color = get_color(index);
	
	if (alpha_double) {
		color.a = min(color.a * 2.0, 1.0);
	}
	
	COLOR = color;

	if (index == hover_index) {
		lowp float blend = abs(sin(TIME * 5.0));
		COLOR = mix(vec4(0.0, 0.0, 0.0, 1.0), vec4(0.0, 1.0, 1.0, 1.0), blend);
	}

	if (index >= selecting_min && index <= selecting_max) {
		lowp float blend = abs(sin(TIME * 5.0));
		COLOR = mix(vec4(0.0, 0.0, 0.0, 1.0), vec4(1.0), blend);
	}
}