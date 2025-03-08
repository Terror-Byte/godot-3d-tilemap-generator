// This shader shamelessly stolen from this godot forums post:
// https://godotforums.org/d/36314-draw-grid-on-floor

shader_type spatial;
render_mode cull_disabled;

uniform float gridlineOnEvery = 1.0; // Come up with a better name for this
uniform float lineThickness = 0.01;
uniform vec2 originOffset = vec2(0.0, 0.0);
uniform vec4 color: source_color = vec4(0.0, 0.0, 0.0, 0.5);

varying vec2 pointWorld;

void vertex() {
	// Called for every vertex the material is visible on.
	pointWorld = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz - originOffset;
}

void fragment() {
	// Called for every pixel the material is visible on.
	float thickness = lineThickness / gridlineOnEvery;
	vec2 df = fract(pointWorld / gridlineOnEvery + thickness / 2.0);
	float grid = step(thickness, df.x) * step(thickness, df.y);
	ALBEDO = color.rgb;
	ALPHA = (1.0 - grid) * color.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
