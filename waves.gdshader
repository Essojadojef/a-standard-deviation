shader_type canvas_item;
render_mode blend_mix;

uniform vec2 origin = vec2(.5, .5);
uniform float anim_speed = 10.;
uniform float anim_duration = 2.;
uniform float time_scale = 0.;
uniform float time_offset = 0.;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform sampler3D noise;

uniform vec3 modulate : source_color;

float process_reflection(vec2 uv, float t, vec2 center) {
	float dist = distance(vec2(uv), center);
	float phase = (-dist * 5.) + t;
	float sin_value = sin(clamp(phase * 10., 0, TAU * 10.));
	float saw_value = 1. - phase / 10.;
	return sin_value * saw_value * saw_value;
}

float simple_noise(float t) {
	t = t * 0.735984 + 0.62688;
	return sin(2. * t) + sin(PI * t);
}

void fragment() {
	// common variables
	vec2 uv = COLOR.rg * 2. - 1.;
	float t = time_scale * TIME + time_offset;
	t = mod(t / anim_duration, 1.) * anim_speed;
	
	// no reflections
	//vec2 origin = vec2(0.50000, 0.50000);
	float dist = distance(vec2(uv), origin);
	float phase = (-dist * 5.) + t;
	float value_0 = process_reflection(uv, t, vec2(1, 1) * origin + vec2(0, 0)); // reflect * origin + mirror_position

	// + neighbours
	float value_1 = process_reflection(uv, t, vec2(-1, 1) * origin + vec2(2, 0)) * .4;
	float value_2 = process_reflection(uv, t, vec2(-1, 1) * origin - vec2(2, 0)) * .4;
	float value_3 = process_reflection(uv, t, vec2(1, -1) * origin + vec2(0, 2)) * .4;
	float value_4 = process_reflection(uv, t, vec2(1, -1) * origin - vec2(0, 2)) * .4;
	// x neighbours
	float value_5 = process_reflection(uv, t, vec2(-1, -1) * origin + vec2( 2,  2)) * .15;
	float value_6 = process_reflection(uv, t, vec2(-1, -1) * origin + vec2( 2, -2)) * .15;
	float value_7 = process_reflection(uv, t, vec2(-1, -1) * origin + vec2(-2,  2)) * .15;
	float value_8 = process_reflection(uv, t, vec2(-1, -1) * origin + vec2(-2, -2)) * .15;

	// sum of reflections
	float sum = value_0 + value_1 + value_2 + value_3 + value_4 + value_5 + value_6 + value_7 + value_8;
	// add noise
	sum += (texture(noise, vec3(COLOR.xy, mod(t * .5, 1.))).r * 2. - 1.) * clamp(phase, 0., 1.) * .25;
	//sum += sin(t * 1.48548947 + uv.r * 10.17894563 + uv.g * 10.7987897456 + .79451698);
	/*sum += simple_noise(
		t * 5. * sin(uv.x * 10.) * sin(uv.y * 5.) +
		simple_noise(uv.x * 10.) + simple_noise(uv.y * 5.)
	) - 1.;*/
	//COLOR.rgb = vec3(sum);
	
	COLOR.rgb = texture(screen_texture, SCREEN_UV).rgb;
	COLOR.rgb += clamp(vec3(sum), 0., 1.) * modulate;


}
