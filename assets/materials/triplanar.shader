shader_type spatial;
render_mode specular_blinn;

uniform float uv_scale: hint_range(0.1, 10);

uniform sampler2D albedo_one;
uniform sampler2D height_one;
uniform float roughness_one : hint_range(0,1);

uniform sampler2D albedo_two;
uniform sampler2D height_two;
uniform float roughness_two : hint_range(0,1);

uniform sampler2D albedo_three;
uniform sampler2D height_three;
uniform float roughness_three : hint_range(0,1);

varying vec3 world_pos;
varying vec3 world_normal;

void vertex(){
	world_pos = VERTEX;
	world_normal = NORMAL;
}

vec3 blend_factor(float wa, float wb, float wc, 
                  float ba, float bb, float bc)
{
	wa = wa*2.-1.;
	wb = wb*2.-1.;
	wc = wc*2.-1.;
	
	float a = wa + ba*0.9;
	float b = wb + bb*0.9;
	float c = wc + bc*0.9;
	
	float threshold = 0.1;
	return normalize(vec3(
		smoothstep(-threshold, 0, a),
		smoothstep(-threshold, 0, b),
		smoothstep(-threshold, 0, c)
	));
}

vec3 mix3(vec3 x, vec3 y, vec3 z, vec3 weight){
	float wt = weight.x + weight.y + weight.z;
	return(x*weight.x + y*weight.y + z*weight.z)/wt;
}

float mix3f(float x, float y, float z, vec3 weight){
	float wt = weight.x + weight.y + weight.z;
	if(wt == 0.0){
		return x;
	}
	return(x*weight.x + y*weight.y + z*weight.z)/wt;
}

void fragment(){
	vec3 pos = world_pos;
	vec3 n = normalize(world_normal);
	
	float h1;
	float h2 = texture(height_two, pos.yz*uv_scale).r;
	float h3 = texture(height_two, pos.xy*uv_scale).r;
	vec3 a1;
	if(n.y < 0.) {
		h1 = texture(height_three, pos.xz*uv_scale).r;
		a1 = texture(albedo_three, pos.xz*uv_scale).xyz;
	}
	else {
		h1 = texture(height_one, pos.xz*uv_scale).r;
		a1 = texture(albedo_one, pos.xz*uv_scale).xyz;
	}
	float f1 = abs(n.y)*abs(n.y);
	float f2 = abs(n.x)*abs(n.x);
	float f3 = abs(n.z)*abs(n.z);
	
	vec3 w = blend_factor(f1,f2, f3, h1, h2, h3);
	ALBEDO = mix3(
		a1,
		texture(albedo_two, pos.yz*uv_scale).rgb,
		texture(albedo_two, pos.xy*uv_scale).rgb,
		w);
	
	ROUGHNESS = mix3f(
		roughness_one,
		roughness_two,
		roughness_three,
		w);
}