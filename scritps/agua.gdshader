shader_type canvas_item;

uniform vec4 base_color: source_color = vec4(0.833, 0.954, 1.0, 1.0);
uniform vec4 main_color: source_color = vec4(0, 0.786, 0.97, 1.0);
uniform	sampler2D water_base: repeat_enable, filter_nearest;
uniform sampler2D noise: repeat_enable, filter_nearest;

uniform float scale_water: hint_range(0.1, 10, 0.1) = 1.0;
uniform float scale_water_extra: hint_range(0.1, 10, 0.1) = 1.0;
uniform float rippling: hint_range(0.0, 0.01, 0.001) = 0.1;

varying vec2 world_pos;

uniform sampler2D gradient_edge_texture: filter_nearest;
uniform sampler2D foam_texture: filter_nearest, repeat_enable;
uniform float foam_scale: hint_range(0.0, 10.0, 0.1) = 1.0;


float easeInOut(float t) {
    return t * t * (3.0 - 2.0 * t);
}
float easeInOutSine(float t) {
    return 0.5 * (1.0 - cos(t * 3.1415926));
}
void foam_feature(in vec4 color, in vec2 origin_uv, out vec4 out_color) {
	float gray_value = texture(gradient_edge_texture, origin_uv).r;
	vec2 foam_uv = origin_uv*16.0/float(textureSize(foam_texture, 0).x)*foam_scale;
	vec4 foam_color = texture(foam_texture, foam_uv);
	float alpha =step(gray_value, 85.0/255.0); // filter grayvalue
	out_color = mix(color, foam_color, foam_color.a*color.a*alpha); // 混合foam
	// 85 for my example , gray value edge may be different in your case	
	float t = step(gray_value, 85.0/255.0)*step(gray_value, (1.0 - abs((sin(TIME*1.0+PI/2.0))))*95.0/255.0+14.0/255.0); 
	out_color.a = (1.-t)*out_color.a;
}

void vertex() {
	// Called for every vertex the material is visible on.
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0, 1.0)).xy; 
}

#define float4 vec4
#define lerp mix
void Blend_Overlay_Vec4(vec4 Base, vec4 Blend, float Opacity, out vec4 Out)
{
    vec4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    vec4 result2 = 2.0 * Base * Blend;
    vec4 zeroOrOne = step(Base, vec4(0.5));
    Out = result2 * zeroOrOne + (1.0 - zeroOrOne) * result1;
    Out = mix(Base, Out, Opacity);
}

void Blend_Subtract_float4(float4 Base, float4 Blend, float Opacity, out float4 Out)
{
    Out = Base - Blend;
    Out = lerp(Base, Out, Opacity);
}

void highlight(vec2 uv, int floor_pixels, float scale, out float light){
	
	float pixles = float(floor_pixels);
	uv = floor(uv*pixles)/pixles;
	vec4 noise_value = texture(noise, uv*scale+TIME*.2);
	vec4 noise_value2 = texture(noise, uv*scale-TIME*.2);
	vec4 result;
	Blend_Overlay_Vec4(noise_value, noise_value2, 1.0, result);
	
	vec4 noise_value3 = texture(noise, uv);
	vec4 res2;
	Blend_Subtract_float4(noise_value3, result, 1.0, res2);
	light = step(res2.x,0.6);
}
const float water_base_texture_size = 340.0; // tilset texture
const float noise_texture_size = 512.0;
const float tile_cell_size = 16.0; // tilemap cell size
void fragment() {
        // for effective, get from const parameters
	//float noise_texture_size = float(textureSize(noise, 0).x);
	//float water_base_texture_size = float(textureSize(water_base, 0).x);
	vec2 uv = world_pos/tile_cell_size; 
	vec2 water_uv = uv*tile_cell_size/water_base_texture_size;

	vec2 noise_uv = uv*tile_cell_size/noise_texture_size;
	vec4 noise_color = texture(noise, noise_uv+TIME*.1);
	vec2 offset_rand = noise_color.xy;
	
	float noise_fade = texture(noise, noise_uv).x;
	
	water_uv = mix (water_uv, water_uv - offset_rand, vec2(rippling));
	water_uv = floor(water_uv*water_base_texture_size)/water_base_texture_size; // pixelate
	vec4 water_color = texture(water_base, water_uv*vec2(scale_water, scale_water+scale_water_extra));
	float white_alpha = water_color.a ;//* noise_fade;//step(0.5, noise_fade); // 0 or 1
	white_alpha *= clamp(noise_fade-0.2, 0.0, 1.0);
	water_color = mix(water_color, main_color, 1.0 - white_alpha);
	water_color = mix(water_color, water_color*base_color, white_alpha); // white bar with fade color
	
	

	
	float not_include_edge = (1.0-step(COLOR.r, 0))*(step(COLOR.g, 0))*(step(COLOR.b, 0));
	COLOR = mix(COLOR, water_color, not_include_edge); //
	// highlight
	float light = 0.0;
	highlight(noise_uv, 1024, 20, light);
	COLOR = mix(COLOR, vec4(1.0), step(light, 0.3)*white_alpha*not_include_edge);
	vec4 color;
	foam_feature(COLOR, UV, color);
	COLOR = color;
}

