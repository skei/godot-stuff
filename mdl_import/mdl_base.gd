#tool
extends Reference

# http://tfc.duke.free.fr/coding/mdl-specs-en.html

#----------------------------------------------------------------------

#var importer 	= preload("res://addons/mdl_import/mdl_import.gd").new(self)
#var converter 	= preload("res://addons/mdl_import/mdl_convert.gd").new(self)

var importer 	= null
var converter 	= null

#----------------------------------------------------------------------

var file		= null
var is_loaded	= false
var header		= null
var skins		= []
var texcoords	= []
var triangles	= []
var frames		= []

#----------------------------------------------------------------------
# mdl types
#----------------------------------------------------------------------

#class mdl_header_t:
class MDLHeader:
	var ident						# magic number: "IDPO"
	var version						# version: 6
	var scale			= Vector3()	# scale factor
	var translate		= Vector3()	# translation vector
	var bounding_radius				#
	var eye_position	= Vector3()	# eyes' position
	var num_skins					# number of textures
	var	skin_width					# texture width
	var skin_height					# texture height
	var num_verts					# number of vertices
	var num_tris					# number of triangles
	var num_frames					# number of frames
	var sync_type					# 0 = synchron, 1 = random
	var flags						# state flag
	var size						#

#class mdl_skin_t:
class MDLSkin:
	var group						# 0 = single, 1 = group
	var data						# texture data

#class mdl_groupskin_t:
class MDLSkinGroup:
	var group						# 1 = group
	var nb							# number of pics
	var time						# time duration for each pic
	var data						# texture data

#class mdl_texcoord_t:
class MDLTexCoord:
	var on_seam						#
	#var u							#
	#var v							#
	var uv = Vector2()				#

#class mdl_triangle_t:
class MDLTriangle:
	var front_facing				# 0 = backface, 1 = frontface
	var v1							# vertex indices
	var v2							#
	var v3							#

#class mdl_vertex_t:
class MDLVertex:
	#var x							#
	#var y							#
	#var z							#
	var pos = Vector3()				#
	var normal						#

#class mdl_simpleframe_t:
class MDLSimpleFrame:
	var type						# 0 = simple
	var bboxmin						# bounding box min
	var bboxmax						# bounding box max
	var name = String()				# char name[16]
	var verts						# vertex list of the frame

#class mdl_framegroup_t:
class MDLFrameGroup:
	var type						# !0 = group
	var min_						# min pos in all simple frames
	var max_						# max pos in all simple frames
	var time = Array()						# time duration for each frame
	var frames = Array()			# simple frame list

#----------------------------------------------------------------------

#const mdl_palette = [
const MDLPalette = [
	"#000000","#0f0f0f","#1f1f1f","#2f2f2f","#3f3f3f","#4b4b4b","#5b5b5b","#6b6b6b",
	"#7b7b7b","#8b8b8b","#9b9b9b","#ababab","#bbbbbb","#cbcbcb","#dbdbdb","#ebebeb",
	"#0f0b07","#170f0b","#1f170b","#271b0f","#2f2313","#372b17","#3f2f17","#4b371b",
	"#533b1b","#5b431f","#634b1f","#6b531f","#73571f","#7b5f23","#836723","#8f6f23",
	"#0b0b0f","#13131b","#1b1b27","#272733","#2f2f3f","#37374b","#3f3f57","#474767",
	"#4f4f73","#5b5b7f","#63638b","#6b6b97","#7373a3","#7b7baf","#8383bb","#8b8bcb",
	"#000000","#070700","#0b0b00","#131300","#1b1b00","#232300","#2b2b07","#2f2f07",
	"#373707","#3f3f07","#474707","#4b4b0b","#53530b","#5b5b0b","#63630b","#6b6b0f",
	"#070000","#0f0000","#170000","#1f0000","#270000","#2f0000","#370000","#3f0000",
	"#470000","#4f0000","#570000","#5f0000","#670000","#6f0000","#770000","#7f0000",
	"#131300","#1b1b00","#232300","#2f2b00","#372f00","#433700","#4b3b07","#574307",
	"#5f4707","#6b4b0b","#77530f","#835713","#8b5b13","#975f1b","#a3631f","#af6723",
	"#231307","#2f170b","#3b1f0f","#4b2313","#572b17","#632f1f","#733723","#7f3b2b",
	"#8f4333","#9f4f33","#af632f","#bf772f","#cf8f2b","#dfab27","#efcb1f","#fff31b",
	"#0b0700","#1b1300","#2b230f","#372b13","#47331b","#533723","#633f2b","#6f4733",
	"#7f533f","#8b5f47","#9b6b53","#a77b5f","#b7876b","#c3937b","#d3a38b","#e3b397",
	"#ab8ba3","#9f7f97","#937387","#8b677b","#7f5b6f","#775363","#6b4b57","#5f3f4b",
	"#573743","#4b2f37","#43272f","#371f23","#2b171b","#231313","#170b0b","#0f0707",
	"#bb739f","#af6b8f","#a35f83","#975777","#8b4f6b","#7f4b5f","#734353","#6b3b4b",
	"#5f333f","#532b37","#47232b","#3b1f23","#2f171b","#231313","#170b0b","#0f0707",
	"#dbc3bb","#cbb3a7","#bfa39b","#af978b","#a3877b","#977b6f","#876f5f","#7b6353",
	"#6b5747","#5f4b3b","#533f33","#433327","#372b1f","#271f17","#1b130f","#0f0b07",
	"#6f837b","#677b6f","#5f7367","#576b5f","#4f6357","#475b4f","#3f5347","#374b3f",
	"#2f4337","#2b3b2f","#233327","#1f2b1f","#172317","#0f1b13","#0b130b","#070b07",
	"#fff31b","#efdf17","#dbcb13","#cbb70f","#bba70f","#ab970b","#9b8307","#8b7307",
	"#7b6307","#6b5300","#5b4700","#4b3700","#3b2b00","#2b1f00","#1b0f00","#0b0700",
	"#0000ff","#0b0bef","#1313df","#1b1bcf","#2323bf","#2b2baf","#2f2f9f","#2f2f8f",
	"#2f2f7f","#2f2f6f","#2f2f5f","#2b2b4f","#23233f","#1b1b2f","#13131f","#0b0b0f",
	"#2b0000","#3b0000","#4b0700","#5f0700","#6f0f00","#7f1707","#931f07","#a3270b",
	"#b7330f","#c34b1b","#cf632b","#db7f3b","#e3974f","#e7ab5f","#efbf77","#f7d38b",
	"#a77b3b","#b79b37","#c7c337","#e7e357","#7fbfff","#abe7ff","#d7ffff","#670000",
	"#8b0000","#b30000","#d70000","#ff0000","#fff393",
	#"#fff7c7","#ffffff","#9f5b53"
	"#ff000000","#ff000000","#ff000000"
]

#----------

const MDLNormals = [
	Vector3(-0.525731,  0.000000,  0.850651),
	Vector3(-0.442863,  0.238856,  0.864188),
	Vector3(-0.295242,  0.000000,  0.955423),
	Vector3(-0.309017,  0.500000,  0.809017),
	Vector3(-0.162460,  0.262866,  0.951056),
	Vector3( 0.000000,  0.000000,  1.000000),
	Vector3( 0.000000,  0.850651,  0.525731),
	Vector3(-0.147621,  0.716567,  0.681718),
	Vector3( 0.147621,  0.716567,  0.681718),
	Vector3( 0.000000,  0.525731,  0.850651),
	Vector3( 0.309017,  0.500000,  0.809017),
	Vector3( 0.525731,  0.000000,  0.850651),
	Vector3( 0.295242,  0.000000,  0.955423),
	Vector3( 0.442863,  0.238856,  0.864188),
	Vector3( 0.162460,  0.262866,  0.951056),
	Vector3(-0.681718,  0.147621,  0.716567),
	Vector3(-0.809017,  0.309017,  0.500000),
	Vector3(-0.587785,  0.425325,  0.688191),
	Vector3(-0.850651,  0.525731,  0.000000),
	Vector3(-0.864188,  0.442863,  0.238856),
	Vector3(-0.716567,  0.681718,  0.147621),
	Vector3(-0.688191,  0.587785,  0.425325),
	Vector3(-0.500000,  0.809017,  0.309017),
	Vector3(-0.238856,  0.864188,  0.442863),
	Vector3(-0.425325,  0.688191,  0.587785),
	Vector3(-0.716567,  0.681718, -0.147621),
	Vector3(-0.500000,  0.809017, -0.309017),
	Vector3(-0.525731,  0.850651,  0.000000),
	Vector3( 0.000000,  0.850651, -0.525731),
	Vector3(-0.238856,  0.864188, -0.442863),
	Vector3( 0.000000,  0.955423, -0.295242),
	Vector3(-0.262866,  0.951056, -0.162460),
	Vector3( 0.000000,  1.000000,  0.000000),
	Vector3( 0.000000,  0.955423,  0.295242),
	Vector3(-0.262866,  0.951056,  0.162460),
	Vector3( 0.238856,  0.864188,  0.442863),
	Vector3( 0.262866,  0.951056,  0.162460),
	Vector3( 0.500000,  0.809017,  0.309017),
	Vector3( 0.238856,  0.864188, -0.442863),
	Vector3( 0.262866,  0.951056, -0.162460),
	Vector3( 0.500000,  0.809017, -0.309017),
	Vector3( 0.850651,  0.525731,  0.000000),
	Vector3( 0.716567,  0.681718,  0.147621),
	Vector3( 0.716567,  0.681718, -0.147621),
	Vector3( 0.525731,  0.850651,  0.000000),
	Vector3( 0.425325,  0.688191,  0.587785),
	Vector3( 0.864188,  0.442863,  0.238856),
	Vector3( 0.688191,  0.587785,  0.425325),
	Vector3( 0.809017,  0.309017,  0.500000),
	Vector3( 0.681718,  0.147621,  0.716567),
	Vector3( 0.587785,  0.425325,  0.688191),
	Vector3( 0.955423,  0.295242,  0.000000),
	Vector3( 1.000000,  0.000000,  0.000000),
	Vector3( 0.951056,  0.162460,  0.262866),
	Vector3( 0.850651, -0.525731,  0.000000),
	Vector3( 0.955423, -0.295242,  0.000000),
	Vector3( 0.864188, -0.442863,  0.238856),
	Vector3( 0.951056, -0.162460,  0.262866),
	Vector3( 0.809017, -0.309017,  0.500000),
	Vector3( 0.681718, -0.147621,  0.716567),
	Vector3( 0.850651,  0.000000,  0.525731),
	Vector3( 0.864188,  0.442863, -0.238856),
	Vector3( 0.809017,  0.309017, -0.500000),
	Vector3( 0.951056,  0.162460, -0.262866),
	Vector3( 0.525731,  0.000000, -0.850651),
	Vector3( 0.681718,  0.147621, -0.716567),
	Vector3( 0.681718, -0.147621, -0.716567),
	Vector3( 0.850651,  0.000000, -0.525731),
	Vector3( 0.809017, -0.309017, -0.500000),
	Vector3( 0.864188, -0.442863, -0.238856),
	Vector3( 0.951056, -0.162460, -0.262866),
	Vector3( 0.147621,  0.716567, -0.681718),
	Vector3( 0.309017,  0.500000, -0.809017),
	Vector3( 0.425325,  0.688191, -0.587785),
	Vector3( 0.442863,  0.238856, -0.864188),
	Vector3( 0.587785,  0.425325, -0.688191),
	Vector3( 0.688191,  0.587785, -0.425325),
	Vector3(-0.147621,  0.716567, -0.681718),
	Vector3(-0.309017,  0.500000, -0.809017),
	Vector3( 0.000000,  0.525731, -0.850651),
	Vector3(-0.525731,  0.000000, -0.850651),
	Vector3(-0.442863,  0.238856, -0.864188),
	Vector3(-0.295242,  0.000000, -0.955423),
	Vector3(-0.162460,  0.262866, -0.951056),
	Vector3( 0.000000,  0.000000, -1.000000),
	Vector3( 0.295242,  0.000000, -0.955423),
	Vector3( 0.162460,  0.262866, -0.951056),
	Vector3(-0.442863, -0.238856, -0.864188),
	Vector3(-0.309017, -0.500000, -0.809017),
	Vector3(-0.162460, -0.262866, -0.951056),
	Vector3( 0.000000, -0.850651, -0.525731),
	Vector3(-0.147621, -0.716567, -0.681718),
	Vector3( 0.147621, -0.716567, -0.681718),
	Vector3( 0.000000, -0.525731, -0.850651),
	Vector3( 0.309017, -0.500000, -0.809017),
	Vector3( 0.442863, -0.238856, -0.864188),
	Vector3( 0.162460, -0.262866, -0.951056),
	Vector3( 0.238856, -0.864188, -0.442863),
	Vector3( 0.500000, -0.809017, -0.309017),
	Vector3( 0.425325, -0.688191, -0.587785),
	Vector3( 0.716567, -0.681718, -0.147621),
	Vector3( 0.688191, -0.587785, -0.425325),
	Vector3( 0.587785, -0.425325, -0.688191),
	Vector3( 0.000000, -0.955423, -0.295242),
	Vector3( 0.000000, -1.000000,  0.000000),
	Vector3( 0.262866, -0.951056, -0.162460),
	Vector3( 0.000000, -0.850651,  0.525731),
	Vector3( 0.000000, -0.955423,  0.295242),
	Vector3( 0.238856, -0.864188,  0.442863),
	Vector3( 0.262866, -0.951056,  0.162460),
	Vector3( 0.500000, -0.809017,  0.309017),
	Vector3( 0.716567, -0.681718,  0.147621),
	Vector3( 0.525731, -0.850651,  0.000000),
	Vector3(-0.238856, -0.864188, -0.442863),
	Vector3(-0.500000, -0.809017, -0.309017),
	Vector3(-0.262866, -0.951056, -0.162460),
	Vector3(-0.850651, -0.525731,  0.000000),
	Vector3(-0.716567, -0.681718, -0.147621),
	Vector3(-0.716567, -0.681718,  0.147621),
	Vector3(-0.525731, -0.850651,  0.000000),
	Vector3(-0.500000, -0.809017,  0.309017),
	Vector3(-0.238856, -0.864188,  0.442863),
	Vector3(-0.262866, -0.951056,  0.162460),
	Vector3(-0.864188, -0.442863,  0.238856),
	Vector3(-0.809017, -0.309017,  0.500000),
	Vector3(-0.688191, -0.587785,  0.425325),
	Vector3(-0.681718, -0.147621,  0.716567),
	Vector3(-0.442863, -0.238856,  0.864188),
	Vector3(-0.587785, -0.425325,  0.688191),
	Vector3(-0.309017, -0.500000,  0.809017),
	Vector3(-0.147621, -0.716567,  0.681718),
	Vector3(-0.425325, -0.688191,  0.587785),
	Vector3(-0.162460, -0.262866,  0.951056),
	Vector3( 0.442863, -0.238856,  0.864188),
	Vector3( 0.162460, -0.262866,  0.951056),
	Vector3( 0.309017, -0.500000,  0.809017),
	Vector3( 0.147621, -0.716567,  0.681718),
	Vector3( 0.000000, -0.525731,  0.850651),
	Vector3( 0.425325, -0.688191,  0.587785),
	Vector3( 0.587785, -0.425325,  0.688191),
	Vector3( 0.688191, -0.587785,  0.425325),
	Vector3(-0.955423,  0.295242,  0.000000),
	Vector3(-0.951056,  0.162460,  0.262866),
	Vector3(-1.000000,  0.000000,  0.000000),
	Vector3(-0.850651,  0.000000,  0.525731),
	Vector3(-0.955423, -0.295242,  0.000000),
	Vector3(-0.951056, -0.162460,  0.262866),
	Vector3(-0.864188,  0.442863, -0.238856),
	Vector3(-0.951056,  0.162460, -0.262866),
	Vector3(-0.809017,  0.309017, -0.500000),
	Vector3(-0.864188, -0.442863, -0.238856),
	Vector3(-0.951056, -0.162460, -0.262866),
	Vector3(-0.809017, -0.309017, -0.500000),
	Vector3(-0.681718,  0.147621, -0.716567),
	Vector3(-0.681718, -0.147621, -0.716567),
	Vector3(-0.850651,  0.000000, -0.525731),
	Vector3(-0.688191,  0.587785, -0.425325),
	Vector3(-0.587785,  0.425325, -0.688191),
	Vector3(-0.425325,  0.688191, -0.587785),
	Vector3(-0.425325, -0.688191, -0.587785),
	Vector3(-0.587785, -0.425325, -0.688191),
	Vector3(-0.688191, -0.587785, -0.425325)
]

#----------

const MDLShader = String("""

shader_type spatial;
//render_mode unshaded;
uniform sampler2D	skin;
uniform sampler2D	anim;
uniform sampler2D	norm;

uniform float		scale;

uniform int			start_frame;
uniform int			end_frame;
uniform bool        interpolate = true;
uniform bool        wraparound = true;

uniform bool        automate = false;
uniform float		speed : hint_range(0, 10) = 1;
uniform float		anim_offset : hint_range(0, 1) = 0;


void vertex() {
	
	int r8 = int(trunc(COLOR.r * 255.0));
	int g8 = int(trunc(COLOR.g * 255.0));
	int b8 = int(trunc(COLOR.b * 255.0));
	int vtx = r8 + (g8 << 8) + (b8 << 16);
	
	float anim_pos = 0.0;

	int num_frames = end_frame - start_frame;
	if (num_frames > 0) {
		if (automate) {
			anim_pos = fract(TIME * speed / (float(num_frames))) ;
		}
	}
	
	float f = float(start_frame);
	f += (float(num_frames) + 0.999) * (anim_pos + anim_offset);
	//f = min(f,float(end_frame) - 0.00001);
	int frm = int(trunc(f));

	vec4 texel;
	vec4 n;
	if (interpolate) {
		ivec2 uv1 = ivec2(vtx,frm);
		float fraction = fract(f);
		ivec2 uv2;
		if ((frm == end_frame) && wraparound) {
			uv2 = ivec2(vtx,start_frame);
		}
		else {
			uv2 = ivec2(vtx,frm+1);
		}
		vec4 texel1 = texelFetch(anim,uv1,0) * scale;
		vec4 texel2 = texelFetch(anim,uv2,0) * scale;
		texel = mix(texel1,texel2,fraction);
		vec4 n1 = texelFetch(norm,uv1,0) * scale;
		vec4 n2 = texelFetch(norm,uv2,0) * scale;
		n = mix(n1,n2,fraction);
	}
	else {
		ivec2 uv1 = ivec2(vtx,frm);
		texel = texelFetch(anim,uv1,0) * scale;
		n = texelFetch(norm,uv1,0);
	}
	VERTEX = vec3(texel.xyz);
	NORMAL = vec3(n.xyz);
}

void fragment() {
	ALBEDO = texture(skin,UV).rgb;
}

""")

#----------------------------------------------------------------------

func print_header():
	#print(filename)
	print("  ident           : " + str(header.ident))
	print("  version         : " + str(header.version))
	print("  scale           : " + str(header.scale))
	print("  translate       : " + str(header.translate))
	print("  bounding_radius : " + str(header.bounding_radius))
	print("  eye_position    : " + str(header.eye_position))
	print("  num_skins       : " + str(header.num_skins))
	print("  skin_width      : " + str(header.skin_width))
	print("  skin_height     : " + str(header.skin_height))
	print("  num_verts       : " + str(header.num_verts))
	print("  num_triangles   : " + str(header.num_tris))
	print("  num_frames      : " + str(header.num_frames))
	print("  sync_type       : " + str(header.sync_type))
	print("  flags           : " + str(header.flags))
	print("  size            : " + str(header.size))

#----------

func print_skins():
	for i in range(header.num_skins):
		print("skin " + str(i) + " group " + str(skins[i].group))

#----------

#class MDLSimpleFrame:
#	var type						# 0 = simple
#	var bboxmin						# bounding box min
#	var bboxmax						# bounding box max
#	var name = String()				# char name[16]
#	var verts						# vertex list of the frame
#
#class MDLFrameGroup:
#	var type						# !0 = group
#	var min_						# min pos in all simple frames
#	var max_						# max pos in all simple frames
#	var time = Array()						# time duration for each frame
#	var frames = Array()			# simple frame list
#
#class MDLVertex:
#	var pos = Vector3()				#
#	var normal						#

#----------

func print_vertex(f,v):
	var vertex = frames[f].verts[v]
	print("    vertex %d pos %f,%f,%f normal %d" % [v,vertex.pos.x,vertex.pos.y,vertex.pos.z,vertex.normal])

#----------

func print_vertices(f):
	for v in range(header.num_verts):
		print_vertex(f,v)

#----------

func print_frame(f):
	match(frames[f].type):
		0:
			print("  type " + str(frames[f].type))
			print("  bboxmin " + str(frames[f].bboxmin))
			print("  bboxmax " + str(frames[f].bboxmax))
			print("  name " + frames[f].name)
			#print_vertices(f)
		_:
			print("  type " + str(frames[f].type))
			print("  min " + str(frames[f].min_))
			print("  max " + str(frames[f].max_))
			#print_vertices(f)

#----------

func print_frames():
	for i in range(header.num_frames):
		print("frame " + str(i))

#----------

#func print_texcoords():
#	for i in range(header.num_verts):
#		print("skin " + str(i))

#----------

#func print_vertices(frame):
#	for i in range(header.num_verts):
#		print("vertex " + str(i))

#----------

#func print_triangles():
#	for i in range(header.num_tris):
#		print("triangle " + str(i))

#----------------------------------------------------------------------

func _init():
	print("mdl_base._init")
	importer = load("res://addons/mdl_import/mdl_import.gd").new(self)
	converter = load("res://addons/mdl_import/mdl_convert.gd").new(self)

#----------

func reset():
	header = null
	skins.clear()
	texcoords.clear()
	triangles.clear()
	frames.clear()
	file = null
	is_loaded = false
