shader_type canvas_item;

// Stepped line-boil: UV jitter at ~8fps, 3-frame feel.
uniform float boil_strength : hint_range(0.0, 0.02) = 0.006;
uniform float fps = 8.0;
uniform bool enabled = true;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	if (enabled) {
		float t = floor(TIME * fps);
		float n = hash(vec2(t, t * 0.37));
		float n2 = hash(vec2(t * 1.7, t));
		uv += (vec2(n, n2) - 0.5) * boil_strength;
	}
	COLOR = texture(TEXTURE, uv);
}
