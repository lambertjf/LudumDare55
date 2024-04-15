shader_type spatial;

uniform vec4 low_color: source_color = vec4(0, 0, 0, 1.0);
uniform vec4 high_color: source_color = vec4(0, 0, 0, 1.0);
uniform vec2 scroll_speed = vec2(0.01, 0.0);
uniform vec2 scroll_speed_2 = vec2(0.01, 0.0);

uniform float height_scale = 0.5;
uniform float light_mod = 0.01;
uniform sampler2D noise;
uniform sampler2D noise_two;

varying vec2 tex_position_1;
varying vec2 tex_position_2;
varying float v_height;

void vertex() {
	 // Adjust this for desired speed and direction
	tex_position_1 = VERTEX.xz + scroll_speed * TIME;
	tex_position_2 = VERTEX.xz + scroll_speed_2 * TIME;

	float height = texture(noise, tex_position_1).x + 3.0 * texture(noise_two, tex_position_2).x;
	VERTEX.y += height * height_scale;
	v_height = height / 4.0;
}

void fragment() {
	ALBEDO =  mix(low_color, high_color, clamp(v_height, 0.0, 1.0)).rgb;
}