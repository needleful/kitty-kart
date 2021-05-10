shader_type spatial;
render_mode specular_blinn;

uniform sampler2D albedo_one;
uniform sampler2D height_one;
uniform float roughness_one : hint_range(0,1);

uniform sampler2D albedo_two;
uniform sampler2D height_two;
uniform float roughness_two : hint_range(0,1);

uniform sampler2D albedo_three;
uniform sampler2D height_three;
uniform float roughness_three : hint_range(0,1);

uniform sampler2D albedo_four;
uniform sampler2D height_four;
uniform float roughness_four: hint_range(0,1);

vec4 blend_factor(float wa, float wb, float wc, 
                  float bbase, float ba, float bb, float bc)
{
	float wbase = 0.545*(1.-wa-wb-wc);
	wbase = wbase*2.-1.;
	wa = wa*2.-1.;
	wb = wb*2.-1.;
	wc = wc*2.-1.;
	
	float a = wa + ba;
	float b = wb + bb;
	float c = wc + bc;
	float base = wbase + bbase;
	
	float mx = max(max(a,b), max(c,base));
	
	float threshold = 0.1;
	return normalize(vec4(
		smoothstep(-threshold, 0, base-mx),
		smoothstep(-threshold, 0, a-mx),
		smoothstep(-threshold, 0, b-mx),
		smoothstep(-threshold, 0, c-mx)
	));
}

vec4 mix4(vec4 x, vec4 y, vec4 z, vec4 w, vec4 weight){
	float wt = weight.x + weight.y + weight.z + weight.w;
	return(x*weight.x + y*weight.y + z*weight.z + w*weight.w)/wt;
}
float mix4f(float x, float y, float z, float w, vec4 weight){
	float wt = weight.x + weight.y + weight.z + weight.w;
	if(wt == 0.0){
		return x;
	}
	return(x*weight.x + y*weight.y + z*weight.z + w*weight.w)/wt;
}

void fragment(){
	float h1 = texture(height_one, UV).r;
	float h2 = texture(height_two, UV).r;
	float h3 = texture(height_three, UV).r;
	float h4 = texture(height_four, UV).r;
	
	float f2 = COLOR.r;
	float f3 = COLOR.g;
	float f4 = COLOR.b;
	
	vec4 w = blend_factor(f2,f3,f4, h1, h2, h3, h4);	
	ALBEDO = mix4(
		texture(albedo_one, UV), 
		texture(albedo_two, UV),
		texture(albedo_three, UV),
		texture(albedo_four, UV),
		w).rgb;
//	ALBEDO = COLOR.rgb;
//	ALBEDO = COLOR.rgb-w.yzw;
//	ALBEDO = mix4(
//		vec4(0),
//		vec4(1,0,0,0),
//		vec4(0,1,0,0),
//		vec4(0,0,1,0),
//		w).rgb;
	ROUGHNESS = mix4f(
		roughness_one,
		roughness_two,
		roughness_three,
		roughness_four,
		w);
}