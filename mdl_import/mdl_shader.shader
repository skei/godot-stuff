shader_type spatial;
//render_mode unshaded;

//----------------------------------------------------------------------

uniform vec3		scale = vec3(1,1,1);
uniform vec3		translate = vec3(0,0,0);
//uniform float		size = 1.0;
uniform int			start_frame = 0;
uniform int			end_frame = 0;
uniform bool		interpolate = true;
uniform bool		wraparound = true;
uniform bool		automate = true;
uniform float		fps : hint_range(0, 60) = 10;
uniform float		anim_offset : hint_range(0, 1) = 0;
uniform int			num_skins : hint_range(1, 256) = 1;
uniform int			skin_index : hint_range(0, 255) = 0;
uniform sampler2D	skin_texture;
uniform sampler2D	vertex_texture;
uniform sampler2D	normal_texture;

const float INV_255 = (1.0)/(255.0);

//----------------------------------------------------------------------

int get_vertex_index(vec3 color) {
	int r8 = int(trunc(color.r * 255.0));
	int g8 = int(trunc(color.g * 255.0));
	int b8 = int(trunc(color.b * 255.0));
	int index = r8 + (g8 << 8) + (b8 << 16);
	return index;
}

float get_anim_pos(float time) {
	float anim_pos = 0.0;
	int num_frames = end_frame - start_frame;
	if ((num_frames > 0) && automate) {
		anim_pos = fract( time * fps / float(num_frames) );
	}
	return anim_pos;
}

float get_anim_frame(float anim_pos) {
	int num_frames = end_frame - start_frame;
	float frame = float(start_frame);
	frame += (float(num_frames) + 0.999) * anim_pos;
	return frame;
}

ivec2 get_uv1(int x,int y) {
	return ivec2(x,y);
}

ivec2 get_uv2(int x,int y) {
	if (y == end_frame) {
		if (wraparound) return ivec2(x,start_frame);
		else return ivec2(x,end_frame);
	}
	else return ivec2(x,y+1);
	return ivec2(0,0);
}

vec4 get_texel1(sampler2D tex, ivec2 uv1) {
	return texelFetch(tex,uv1,0);
}

vec4 get_texel2(sampler2D tex, ivec2 uv1, ivec2 uv2, float fraction) {
	vec4 texel1 = texelFetch(tex,uv1,0);
	vec4 texel2 = texelFetch(tex,uv2,0);
	return mix(texel1,texel2,fraction);
}

vec4 get_texel(sampler2D tex, ivec2 uv1, ivec2 uv2, float fraction) {
	if (interpolate) {
		return get_texel2(tex,uv1,uv2,fraction);
	}
	else {
		return get_texel1(tex,uv1);
	}
}

//----------------------------------------------------------------------

void vertex() {
	int vtx = get_vertex_index(COLOR.rgb);
	float anim_pos = get_anim_pos(TIME);
	float frame = get_anim_frame(anim_pos + anim_offset);
	int iframe = int(trunc(frame));
	float fframe = fract(frame);
	ivec2 uv1 = get_uv1(vtx,iframe);
	ivec2 uv2 = get_uv2(vtx,iframe);
	vec3 pos = get_texel(vertex_texture,uv1,uv2,fframe).xyz;
	vec4 normal = get_texel(normal_texture,uv1,uv2,fframe);
	
	//pos *= scale;
	//pos += translate;
	
	//VERTEX = vec3(pos.x,pos.z,-pos.y);
	//NORMAL = vec3(normal.x,normal.z,-normal.y);
	VERTEX = vec3(pos.x,pos.y,pos.z);
	NORMAL = vec3(normal.x,normal.y,normal.z);

	//vec3 p = pos.xzy;
	//p.y = -p.y;
	//vec3 n = normal.xzy;
	//n.y = -n.y;
	//VERTEX = p * ;
	//NORMAL = n;
	
}

//----------

void fragment() {
	float skin_scale = 1.0 / float(num_skins);
	float skin_offset = float(skin_index) * skin_scale;
	vec2 uv = vec2( UV.x, (UV.y * skin_scale) + skin_offset );
	ALBEDO = texture(skin_texture,uv).rgb;
}
