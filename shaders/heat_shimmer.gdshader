shader_type canvas_item;

uniform float strength : hint_range(0.0, 0.05) = 0.012;
uniform float speed = 1.5;

void fragment() {
	vec2 uv = UV;
	uv.x += sin(UV.y * 40.0 + TIME * speed) * strength;
	uv.y += cos(UV.x * 30.0 + TIME * speed * 0.7) * strength * 0.5;
	COLOR = texture(TEXTURE, uv);
	COLOR.a *= 0.35;
}
