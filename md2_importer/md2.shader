shader_type spatial;
//render_mode unshaded;

//----------------------------------------------------------------------

uniform vec3      _scale = vec3(1,1,1);
uniform vec3      _translate = vec3(0,0,0);
uniform int       _start_frame = 0;
uniform int       _end_frame = 0;
uniform bool      _interpolate = true;
uniform bool      _wraparound = true;
uniform bool      _automate = true;
uniform float     _fps : hint_range(0, 60) = 6;
uniform float     _anim_offset : hint_range(0, 1) = 0;
uniform int       _num_skins : hint_range(1, 256) = 1;
uniform int       _skin_index : hint_range(0, 255) = 0;
uniform sampler2D _skin_texture;
uniform sampler2D _vertex_texture;
uniform sampler2D _normal_texture;
uniform sampler2D _frame_data_texture;

const float INV_255 = (1.0)/(255.0);

//----------------------------------------------------------------------

vec4 read_texel(sampler2D tex, int x, int y, float f) {
	//ivec2 uv1 = ivec2(vtx,frame);
	//ivec2 uv2 = ivec2(vtx,frame+1);
	int y2 = y + 1;
	if (y == _end_frame) {
		if (_wraparound) y2 = _start_frame;
		else y2 = _end_frame;
	}
	vec4 texel1 = texelFetch(tex,ivec2(x,y),0);
	vec4 texel2 = texelFetch(tex,ivec2(x,y2),0);
	return  mix(texel1,texel2,f);
}

//----------

void calc_frame(float time, out int iframe, out float fframe) {
	float anim_pos = 0.0;
	int num_frames = _end_frame - _start_frame;
	if ((num_frames > 0) && _automate) {
		anim_pos = fract( time * _fps / float(num_frames) );
	}
	float frame = float(_start_frame);
	frame += (float(num_frames) + 0.999) * anim_pos;
	iframe   = int(trunc(frame));
	fframe   = fract(frame);
}

//----------------------------------------------------------------------

void vertex() {
	int vtx = (int(UV2.x) * 256) + int(UV2.y);
	int iframe;
	float fframe;
	calc_frame(TIME,iframe,fframe);
	
	vec3 pos = read_texel(_vertex_texture,vtx,iframe,fframe).xyz;
	vec3 normal = read_texel(_normal_texture,vtx,iframe,fframe).xyz;
	normal = (normal * 2.0) - 1.0;
	vec3 scale = read_texel(_frame_data_texture,0,iframe,fframe).xyz;
	
	//vec3 translate = read_texel(_frame_data_texture,1,iframe,fframe).xyz;
	//translate /= 256.0;
	
	vec3 trans_int = read_texel(_frame_data_texture,1,iframe,fframe).xyz;
	vec3 trans_frac = read_texel(_frame_data_texture,2,iframe,fframe).xyz;
	
	//vec3 translate = (trans_int / 256.0) + trans_frac;
	vec3 translate = trans_int;
	translate -= 0.5;
	//vec3 translate = trans_frac;
	//translate = (translate * 2.0) - 1.0;

	pos += translate;
	pos *= scale;
	
	pos *= 5.0;
	pos += 0.5;
	
	VERTEX = vec3(pos.x,pos.z,-pos.y);
	NORMAL = vec3(normal.x,normal.z,-normal.y);
}

//----------

void fragment() {
	float skin_scale = 1.0 / float(_num_skins);
	float skin_offset = float(_skin_index) * skin_scale;
	vec2 uv = vec2( UV.x, (UV.y * skin_scale) + skin_offset );
	vec4 c = texture(_skin_texture,uv);
	ALBEDO = c.rgb;
	if (c.a < 0.5) discard;
	//ALPHA = c.a;
}
