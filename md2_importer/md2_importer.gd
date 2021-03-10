tool
extends EditorImportPlugin

# https://docs.godotengine.org/en/stable/tutorials/plugins/editor/import_plugins.html

#----------------------------------------------------------------------

enum Presets { DEFAULT }

#var md2_loader = preload("md2_loader.gd").new()

const INV_255 = (1.0 / 255.0)

var _file = null
var _path = String("")
var _is_loaded = false
var _header = md2_header.new()
var _skins = [] # Array()
var _texcoords = [] # Array()
var _triangles = [] # Array()
var _frames = [] # Array()


#----------------------------------------------------------------------

func get_importer_name():
	return "md2_importer"

#----------

func get_visible_name():
	return "md2"

#----------

func get_recognized_extensions():
	return ["md2"]

#----------

func get_save_extension():
	return "tres"

#----------

func get_resource_type():
	return "ArrayMesh"


#----------

func get_preset_count():
	return Presets.size()

#----------

func get_preset_name(preset):
	match preset:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"

#----------

func get_import_options(preset):
	match preset:
		Presets.DEFAULT:
			return [
				{
					"name" : "import_as",
					"default_value" : "scene",
					"property_hint" : PROPERTY_HINT_ENUM,
					"hint_string" : "scene,mesh"
					#"usage" : "" # optional
				},
				{
					"name" : "frame",
					"default_value" : 0
					#"property_hint" : PROPERTY_HINT_NONE # optional
					#"hint_string" : "2" # optional
					#"usage" : "" # optional
				},
				{
					"name" : "skin",
					"default_value" : 0
					#"property_hint" : PROPERTY_HINT_NONE # optional
					#"hint_string" : "2" # optional
					#"usage" : "" # optional
				},
				{
					"name" : "palette",
					"default_value" : "quake",
					"property_hint" : PROPERTY_HINT_ENUM,
					"hint_string" : "quake,hexen"
					#"usage" : "" # optional
				}
#				{
#					"name" : "export_files",
#					"default_value" : false
#					#"property_hint" : PROPERTY_HINT_NONE # optional
#					#"hint_string" : "2" # optional
#					#"usage" : "" # optional
#				}
			]
		_:
			return []

#----------

func get_option_visibility(option, options):
	return true

#----------------------------------------------------------------------


func import(source_file, save_path, options, r_platform_variants, r_gen_files):
	read(source_file)
	var name = source_file.get_basename()
	var path = source_file.get_base_dir()
	_path = path
	
	var mesh = get_array_mesh(options.frame)
	var material = get_material(options.skin)
	mesh.surface_set_name(0,name)
	mesh.surface_set_material(0,material)
	
	return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], mesh)



#----------------------------------------------------------------------
#
#
#
#----------------------------------------------------------------------


const md2_quake_palette = [
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
	"#00000000","#00000000","#00000000"
]

#----------------------------------------------------------------------
#
#----------------------------------------------------------------------

class md2_header:
	var ident						# magic number: "IDPO"
	var version						# version: 8
	var	skin_width					# texture width
	var skin_height					# texture height
	var frame_size					# size in bytes of a frame
	var num_skins					# number of skins
	var num_vertices				# number of vertices per frame
	var num_st						# number of texture coordinates
	var num_tris					# number of triangles
	var num_glcmds					# number of opengl commands
	var num_frames					# number of frames
	var offset_skins				# offset skin data
	var offset_st					# offset texture coordinate data
	var offset_tris					# offset triangle data
	var offset_frames				# offset frame data
	var offset_glcmds				# offset OpenGL command data
	var offset_end					# offset end of file

# There is an array of numSkins skin names stored at offsetSkins into the file.
# Each skin name is a char[64]. The name is really a path to the skin, relative
# to the base game directory (baseq2 f or "standard" Quake2). The skin files
# are regular pcx files.
#
# typedef struct {
#   short s, t;
# } textureCoordinate_t;
#
# short s, t: These two shorts are used to map a vertex onto a skin. The
# horizontal axis position is given by s, and the vertical axis position is
# given by t. The range for s is greater than or equal to 0 and less than
# skinWidth< /a> (0 <= s < skinWidth). The range for t is greater than or equal
# to 0 and less than skinHeight (0 <= s < skinHeight). N ote that the ranges
# are different than in the s and t members of the glCommandVertex structure. 

class md2_skin:
	var name = String()				# texture file name

# Texture coordinates are stored in a structure as short integers. To get the
# true texture coordinates, you have to divide s by skinwidth and t by
# skinheight
#
# struct md2_texCoord_t {
#   short s;
#   short t;
# }

class md2_texcoord:
	var uv = Vector2()				# short

# Quake 2 models are made up of only triangles. At offsetTriangles in the file
# is an array of triangle_t structures. The array has numTriangles structures
# in it.
#
# typedef struct {
#   short vertexIndices[3];
#   short textureIndices[3];
# } triangle_t;
#
# short vertexIndices: These three shorts are indices into the array of
#   vertices in each frames. In other words, the number of triangles in a md2
#   file is fixed, and each triangle is always made of the same three indices
#   into each frame's array of vertices. So, in each frame, the triangles
#   themselves stay intact, their vertices are just moved around.
# short textureIndices: These three shorts are indices into the array
#   of texture coordinates. 

class md2_triangle:
	var v1							# vertex indices
	var v2							#
	var v3							#
	var uv1							# vertex indices
	var uv2							#
	var uv3							#

# Each frame contains the positions in 3D space for each vertex of each
# triangle that makes up the model. Quake 2 (and Quake) models contain only
# triangles.
#
# typdef struct {
#   byte vertex[3];
#   byte lightNormalIndex;
# } triangleVertex_t;
#
# byte vertex[3]: The three bytes represent the x, y, and z coordinates of this
#   vertex. This is not the "real" vertex coordinate. This is a scaled version
#   of the coordinate, scaled so that each of the three numbers fit within one
#   byte. To scale the vertex back to the "real" coordinate, you need to first
#   multiply each of the bytes by their respective float scale in the frame_t
#   structure, and then add the respective float translation, also in the
#   frame_t structure. This will give you the vertex coordinate relative to the
#   model's origin, which is at the origin, (0, 0, 0).
# byte lightNormalIndex: This is an index into a table of normals

class md2_vertex:
	var pos = Vector3()				#
	var normal						#

# frame_t is a variable sized structure, however all frame_t structures within
# the same file will have the same size (numVertices in the header)
#
# float scale[3]: This is a scale used by the vertex member of the
#   triangleVertex_t structure.
# float translate[3]: This is a translation used by the vertex member of the
#   triangleVertex_t structure.
# char name[16]: This is a name for the frame.
# triangleVertex_t vertices[1]: An array of numVertices triangleVertex_t
#   structures. 

class md2_frame:
	var scale = Vector3()			# scale factor
	var translate = Vector3()		# translation vector
	var name = String()				# frame name
	var verts = Array()				# list of frame's vertices

#----------------------------------------------------------------------
#
#----------------------------------------------------------------------

func read(filename):
	reset()
	_file = File.new()
	if not _file.file_exists(filename):
		print("ERROR: file '" + filename + "' does not exist")
		return ERR_FILE_NOT_FOUND
	_file.open(filename,File.READ)
	read_header()
	print_header()
	read_skins()
	read_texcoords()
	read_triangles()
	read_glcmds()
	read_frames()
	_file.close()
	return OK

#----------

func print_header():
	print("  ident          : " + str(_header.ident))
	print("  version        : " + str(_header.version))
	print("  skin_width     : " + str(_header.skin_width))
	print("  skin_height    : " + str(_header.skin_height))
	print("  frame_size     : " + str(_header.frame_size))
	print("  num_skins      : " + str(_header.num_skins))
	print("  num_vertices   : " + str(_header.num_vertices))
	print("  num_st         : " + str(_header.num_st))
	print("  num_tris       : " + str(_header.num_tris))
	print("  num_glcmds     : " + str(_header.num_glcmds))
	print("  num_frames     : " + str(_header.num_frames))
	print("  offset_skins   : " + str(_header.offset_skins))
	print("  offset_st      : " + str(_header.offset_st))
	print("  offset_tris    : " + str(_header.offset_tris))
	print("  offset_frames  : " + str(_header.offset_frames))
	print("  offset_glcmds  : " + str(_header.offset_glcmds))
	print("  offset_end     : " + str(_header.offset_end))

#----------------------------------------------------------------------
#
#----------------------------------------------------------------------

func reset():
	_header = null
	_skins.clear()
	_texcoords.clear()
	_triangles.clear()
	_frames.clear()
	_file = null
	_is_loaded = false
	pass

#----------

func calc_vertex_normals(fr):
	var vertices = _frames[fr].verts
	#var tri_normals = calc_tri_normals(frame)
	var vert_normals = []
	vert_normals.resize(_header.num_vertices)
	for v in range(_header.num_vertices):
		vert_normals[v] = Vector3()
	for t in range(_header.num_tris):
		var tri = _triangles[t]
		var v1 = vertices[tri.v1].pos
		var v2 = vertices[tri.v2].pos
		var v3 = vertices[tri.v3].pos
		var a = v3 - v1
		var b = v2 - v1
		var normal = a.cross(b)
		#normal = normal.normalized()
		vert_normals[tri.v1] += normal
		vert_normals[tri.v2] += normal
		vert_normals[tri.v3] += normal
	for v in range(_header.num_vertices):
		vert_normals[v] = vert_normals[v].normalized()
	return vert_normals

#----------

#func set_pixel1(image,x,y,vec):
#	var v = vec / 255.0
#	var c = Color( v.x, v.y, v.z, 1.0 )
#	image.set_pixel(x,y,c)

#----------

# https://twitter.com/rygorous/status/1292942936817115136

func hemi_octahedral_encode(v):
	var t = Vector2(v.x,v.y) * (1.0 / (abs(v.x) + abs(v.y) + abs(v.z)))
	return Vector2(t.x + t.y, t.x - t.y) # in [-1,1]^2

func hemi_octahedral_decode(v):
	var t = Vector2(v.x + v.y, v.x - v.y)
	return Vector3( t.x, t.y, 2.0 - abs(t.x) - abs(t.y) ).normalized()

#----------

# https://stackoverflow.com/questions/18453302/how-do-you-pack-one-32bit-int-into-4-8bit-ints-in-glsl-webgl

# packs a floating point value in the range [0.0, 1.0] into a vec4:

#vec4 Encode( in float value ) {
#    value *= (256.0*256.0*256.0 - 1.0) / (256.0*256.0*256.0);
#    vec4 encode = fract( value * vec4(1.0, 256.0, 256.0*256.0, 256.0*256.0*256.0) );
#    return vec4( encode.xyz - encode.yzw / 256.0, encode.w ) + 1.0/512.0;
#}

# extracts a floating point value in the range [0.0, 1.0] from a vec4

#float Decode( in vec4 pack ) {
#    float value = dot( pack, 1.0 / vec4(1.0, 256.0, 256.0*256.0, 256.0*256.0*256.0) );
#    return value * (256.0*256.0*256.0) / (256.0*256.0*256.0 - 1.0);
#}

# The following functions packs and extracts an floating point value in and from the range [minVal, maxVal]

#vec4 EncodeRange( in float value, flaot minVal, maxVal ) {
#    value = clamp( (value-minVal) / (maxVal-minVal), 0.0, 1.0 );
#    value *= (256.0*256.0*256.0 - 1.0) / (256.0*256.0*256.0);
#    vec4 encode = fract( value * vec4(1.0, 256.0, 256.0*256.0, 256.0*256.0*256.0) );
#    return vec4( encode.xyz - encode.yzw / 256.0, encode.w ) + 1.0/512.0;
#}

#float DecodeRange( in vec4 pack, flaot minVal, maxVal ) {
#    value = dot( pack, 1.0 / vec4(1.0, 256.0, 256.0*256.0, 256.0*256.0*256.0) );
#    value *= (256.0*256.0*256.0) / (256.0*256.0*256.0 - 1.0);
#    return mix( minVal, maxVal, value );
#}

#----------

# https://uncommoncode.wordpress.com/2012/11/07/float-packing-in-shaders-encoding-multiple-components-in-one-float/

# color normalized RGB value
# returns 3-component encoded float

const precision = 128.0
const precisionp1 = precision + 1.0

#float color2float(vec3 color) {
#	color = clamp(color, 0.0, 1.0);
#	return floor(color.r * c_precision + 0.5) 
#		+ floor(color.b * c_precision + 0.5) * c_precisionp1
#		+ floor(color.g * c_precision + 0.5) * c_precisionp1 * c_precisionp1;
#}

func vec_to_float(vec):
	vec = clamp(vec, 0.0, 1.0);
	var x = floor(vec.x * precision + 0.5) 
	var y = floor(vec.y * precision + 0.5) * precisionp1
	var z = floor(vec.z * precision + 0.5) * precisionp1 * precisionp1
	return x + y + z

# value = 3-component encoded float
# returns normalized RGB value

#vec3 float2color(float value) {
#	vec3 color;
#	color.r = mod(value, c_precisionp1) / c_precision;
#	color.b = mod(floor(value / c_precisionp1), c_precisionp1) / c_precision;
#	color.g = floor(value / (c_precisionp1 * c_precisionp1)) / c_precision;
#	return color;
#}

func float_to_vec(value):
	var vec = Vector3()
	vec.x = fmod(value, precisionp1) / precision
	vec.y = fmod(floor(value / precisionp1), precisionp1) / precision
	vec.z = floor(value / (precisionp1 * precisionp1)) / precision
#	return color;

#----------

# vector is 0..1
# received as 0..1 in shader

func set_vector(image,x,y,vec):
	#if vec.x > 1.0 or vec.x < 0.0 or vec.y > 1.0 or vec.y < 0.0 or vec.z > 1.0 or vec.z < 0.0:
	#	print(str(vec) + "!!!")
	var c = Color( vec.x, vec.y, vec.z, 1.0 )
	#var int_part = Vector3( floor(vec.x), floor(vec.y), floor(vec.z) )
	#var frac_part = vec - int_part
	image.set_pixel(x,y,c)
	#image.set_pixel((x*2)+1,y,c2)

# vector is -1..1
# received as 0..1 in shader

func set_vector_signed(image,x,y,vec):
	pass

#----------

# vector is -128..127
# received as two floats in shader.. scaled int-part, and fract, part
# value = (int_part * 256.0) + fract_path

func set_vector2(image,x,y,vec):
	vec += 128.0				# .128..128 -> 0..255
	#vec = vec / 255.0							# -255..255 -> -1..1
	#vec = (vec / 2.0) + Vector3(0.5,0.5,0.5) 	# -1..1 -> 0..1
	var int_part = Vector3( floor(vec.x), floor(vec.y), floor(vec.z) )
	var frac_part = vec - int_part
	int_part /= 256.0
	#var f1 = vec_to_float(int_part)
	#var f2 = vec_to_float(frac_part)
	var c1 = Color( int_part.x, int_part.y, int_part.z, 1.0 )
	var c2 = Color( frac_part.x, frac_part.y, frac_part.z, 1.0 )
	image.set_pixel(x,y,c1)
	image.set_pixel(x+1,y,c2)

#	vec /= 256.0
#	vec = (vec * 0.5) + Vector3(0.5,0.5,0.5)
#	#if vec.x > 1.0 or vec.x < 0.0 or vec.y > 1.0 or vec.y < 0.0 or vec.z > 1.0 or vec.z < 0.0:
#	#	print(str(vec) + "!!!")
#	var c = Color( vec.x, vec.y, vec.z, 1.0 )
#	image.set_pixel(x,y,c)

#----------

#func set_pixel2_fp88(image,x,y,vec):
#	var ix = floor(vec.x)
#	var iy = floor(vec.y)
#	var iz = floor(vec.z)
#	var fx = vec.x - ix;
#	var fy = vec.y - iy;
#	var fz = vec.z - iz;
#	var fvec = Vector3(fx,fy,fz);
#	var ivec = Vector3(ix,iy,iz);
#	ivec /= 256.0
#	ivec += Vector3(0.5,0.5,0.5)
#	var fcol = Color( fvec.x, fvec.y, fvec.z, 1.0 )
#	var icol = Color( ivec.x, ivec.y, ivec.z, 1.0 )
#	image.set_pixel(x,y,icol)
#	image.set_pixel(x+1,y,fcol)

#----------

# https://github.com/victorfeitosa/quake-hexen2-mdl-export-import/blob/master/import_mdl.py

#def merge_frames(mdl):
#    def get_base(name):
#        i = 0
#        while i < len(name) and name[i] not in "0123456789":
#            i += 1
#        return name[:i]
#
#    i = 0
#    while i < len(mdl.frames):
#        if mdl.frames[i].type:
#            i += 1
#            continue
#        base = get_base(mdl.frames[i].name)
#        j = i + 1
#        while j < len(mdl.frames):
#            if mdl.frames[j].type:
#                break
#            if get_base(mdl.frames[j].name) != base:
#                break
#            j += 1
#        f = MDL.Frame()
#        f.name = base
#        f.type = 1
#        f.frames = mdl.frames[i:j]
#        mdl.frames[i:j] = [f]
#        i += 1

#----------------------------------------------------------------------
#
#----------------------------------------------------------------------

func read_byte():
	return _file.get_8()

#----------

func _read_short():
	return _file.get_16()

#----------

func read_int():
	return _file.get_32()

#----------

func read_float():
	return _file.get_float()

#----------

func read_vector():
	var x = _file.get_float()
	var y = _file.get_float()
	var z = _file.get_float()
	var v = Vector3(x,y,z)
	return v

#----------

func read_vector8():
	var x = _file.get_8()
	var y = _file.get_8()
	var z = _file.get_8()
	var v = Vector3(x,y,z)
	return v

#----------

func read_string(length):
	var zero = false
	var s = String()
	for _i in range(length):
		var c = _file.get_8()
		if c == 0:
			zero = true
		if not zero:
			s += String("%c" % c)
	return s

#----------

func read_byte_buffer(size):
	var b = _file.get_buffer(size)
	return b

#----------

func read_float_buffer(size):
	var data = _file.get_buffer(size * 4)
	return data

#----------------------------------------------------------------------
# read md2 specific
#----------------------------------------------------------------------

func read_header():
	#print("  reading mdl header")
	_header = md2_header.new()
	_header.ident = read_int()
	if _header.ident != 844121161 :
		print("ERROR: wrong header.ident " + str(_header.ident) + " (should be 844121161 )")
		return ERR_FILE_CORRUPT
	_header.version = read_int()
	if _header.version != 8:
		print("ERROR: wrong header.version " + str(_header.version) + " (should be 8)")
		return ERR_FILE_UNRECOGNIZED
	_header.skin_width = read_int()
	_header.skin_height = read_int()
	_header.frame_size = read_int()
	_header.num_skins = read_int()
	_header.num_vertices = read_int()
	_header.num_st = read_int()
	_header.num_tris = read_int()
	_header.num_glcmds = read_int()
	_header.num_frames = read_int()
	_header.offset_skins = read_int()
	_header.offset_st = read_int()
	_header.offset_tris = read_int()
	_header.offset_frames = read_int()
	_header.offset_glcmds = read_int()
	_header.offset_end = read_int()
	return OK

#----------

# swap x/y

func read_vertex():
	var v = md2_vertex.new()
	var vec = read_vector8()
	#vec *= INV_255
	#vec -= Vector3(0.5,0.5,0.5)
	v.pos = vec
	v.normal = read_byte()
	return v

func read_vertices():
	#print("reading " + str(_header.num_vertices) + " vertices")
	var vert = Array()
	for _i in range(_header.num_vertices):
		var v = read_vertex()
		vert.append( v )
	return vert

#----------

func read_texcoord():
	var tc = md2_texcoord.new()
#	tc.on_seam = _file.get_32()
	var u = _file.get_16()
	var v = _file.get_16()
	var uv = Vector2(u,v)
	#u = (u + 0.5) / _header.skin_width
	#v = (v + 0.5) / _header.skin_height
	#uv.x /=  _header.skin_width
	#uv.y /=  _header.skin_height
	tc.uv = uv
	return tc

func read_texcoords():
	#print("reading " + str(_header.num_st) + " texcoords")
	_file.seek(_header.offset_st)
	for _i in range(_header.num_st):
		var tc = read_texcoord()
		_texcoords.append(tc)

#----------

func read_triangle():
	var t = md2_triangle.new()
#	t.front_facing = _file.get_32() == 1
	t.v1 = _file.get_16()
	t.v2 = _file.get_16()
	t.v3 = _file.get_16()
	t.uv1 = _file.get_16()
	t.uv2 = _file.get_16()
	t.uv3 = _file.get_16()
	return t

func read_triangles():
	#print("reading " + str(_header.num_tris) + " triangles")
	_file.seek(_header.offset_tris)
	for _i in range(_header.num_tris):
		var t = read_triangle()
		_triangles.append(t)

#----------

func read_glcmds():
	_file.seek(_header.offset_glcmds)
	pass

#----------

func read_skin():
	var s = md2_skin.new()
	s.name = read_string(64)
	#print("  name: " + s.name)
	return s

func read_skins():
	#print("reading " + str(_header.num_skins) + " skins")
	_file.seek(_header.offset_skins)
	for _i in range(_header.num_skins):
		var s = read_skin()
		_skins.append(s)

#----------

func read_frame():
	var f = md2_frame.new()
	f.scale = read_vector()
	f.translate = read_vector()
	f.name = read_string(16)
	f.verts = read_vertices()
	return f

func read_frames():
	#print("reading " + str(_header.num_frames) + " frames")
	_file.seek(_header.offset_frames)
	var num = _header.num_frames
	for i in range(num):
		var f = read_frame()
		#rint("frame " + str(i) + " scale " + str(f.scale.x) + "," + str(f.scale.y) + "," + str(f.scale.z)
		#						+ " translate " + str(f.translate.x) + "," + str(f.translate.y) + "," + str(f.translate.z))
		_frames.append(f)

#----------------------------------------------------------------------
#
#----------------------------------------------------------------------

# x,y,z -> x,z,-y

func get_vertex_array(fr):
	var vertices = PoolVector3Array()
	for i in range(_header.num_tris):
		var i1 = _triangles[i].v1;
		var i2 = _triangles[i].v2;
		var i3 = _triangles[i].v3;
		var v1 = _frames[fr].verts[i1].pos / 255.0 # * 100.0
		var v2 = _frames[fr].verts[i2].pos / 255.0 # * 100.0
		var v3 = _frames[fr].verts[i3].pos / 255.0 # * 100.0
		
#		v1 = ((v1 * _header.scale) + _header.translate)
#		v2 = ((v2 * _header.scale) + _header.translate)
#		v3 = ((v3 * _header.scale) + _header.translate)

		var temp
		temp = v1.y
		v1.y = v1.z
		v1.z = -temp
		temp = v2.y
		v2.y = v2.z
		v2.z = -temp
		temp = v3.y
		v3.y = v3.z
		v3.z = -temp
		
		vertices.push_back(v1)
		vertices.push_back(v2)
		vertices.push_back(v3)
	return vertices

#----------

func get_normal_array(frame):
	var normals = PoolVector3Array()
	var vn = calc_vertex_normals(frame)
	for i in range(_header.num_tris):
		var i1 = _triangles[i].v1;
		var i2 = _triangles[i].v2;
		var i3 = _triangles[i].v3;
		var n1 = vn[i1]
		var n2 = vn[i2]
		var n3 = vn[i3]
		var temp
		temp = n1.y
		n1.y = n1.z
		n1.z = -temp
		temp = n2.y
		n2.y = n2.z
		n2.z = -temp
		temp = n3.y
		n3.y = n3.z
		n3.z = -temp
		normals.push_back(n1)
		normals.push_back(n2)
		normals.push_back(n3)
	return normals

#----------

func get_color_array():
	var colors = PoolColorArray()
	for i in range(_header.num_tris):
		var c1 = Color(1,0,0)
		var c2 = Color(0,1,0)
		var c3 = Color(0,0,1)
		colors.push_back(c1)
		colors.push_back(c2)
		colors.push_back(c3)
	return colors

#----------

func get_texcoord1_array():
	var texcoords = PoolVector2Array()
	var skin_size = Vector2(_header.skin_width,_header.skin_height)
	for i in range(_header.num_tris):
		var i1 = _triangles[i].uv1#v1;
		var i2 = _triangles[i].uv2#v2
		var i3 = _triangles[i].uv3#v3
		var uv1 = _texcoords[i1].uv / skin_size
		var uv2 = _texcoords[i2].uv / skin_size
		var uv3 = _texcoords[i3].uv / skin_size
#		if _triangles[i].front_facing == 0:
#			if _texcoords[i1].on_seam > 0:
#				uv1.x += 0.5;
#			if _texcoords[i2].on_seam > 0:
#				uv2.x += 0.5;
#			if _texcoords[i3].on_seam > 0:
#				uv3.x += 0.5;
		texcoords.push_back(uv1)
		texcoords.push_back(uv2)
		texcoords.push_back(uv3)
		#print("  uv1 " + str(i) + ": " + str(uv1.x) + "," + str(uv1.y))
		#print("  uv2 " + str(i) + ": " + str(uv2.x) + "," + str(uv2.y))
		#print("  uv3 " + str(i) + ": " + str(uv3.x) + "," + str(uv3.y))
	return texcoords

#----------

func get_texcoord2_array():
	var texcoords = PoolVector2Array()
	for i in range(_header.num_tris):
		var i1 = (i * 3)
		var i2 = (i * 3) + 1
		var i3 = (i * 3) + 2
		var uv1 = Vector2((i1 & 0xff00) >> 8, i1 & 0x00ff)
		var uv2 = Vector2((i2 & 0xff00) >> 8, i2 & 0x00ff)
		var uv3 = Vector2((i3 & 0xff00) >> 8, i3 & 0x00ff)
		texcoords.push_back(uv1)
		texcoords.push_back(uv2)
		texcoords.push_back(uv3)
	return texcoords

#----------

func get_triangle_array():
	var triangles = PoolIntArray()
	for i in range(_header.num_tris):
		var i1 = (i * 3)
		var i2 = (i * 3) + 1
		var i3 = (i * 3) + 2
		triangles.push_back(i1)
		triangles.push_back(i2)
		triangles.push_back(i3)
	return triangles

#----------------------------------------------------------------------
#
#----------------------------------------------------------------------

func get_description():
	#print("* get_description")
	var d = ""
	#d += "scale:" + str(_header.scale.x) + "," + str(_header.scale.y) + "," + str(_header.scale.z) + "\n"
	#d += "translate:" + str(_header.translate.x) + "," + str(_header.translate.y) + "," + str(_header.translate.z) + "\n"
	#d += "bounding_radius : " + str(_header.bounding_radius) + "\n"
	#d += "eye_position:" + str(_header.eye_position.x) + "," + str(_header.eye_position.y) + "," + str(_header.eye_position.z) + "\n"
	d += "num_skins : " + str(_header.num_skins) + "\n"
	d += "skin_width: " + str(_header.skin_width) + "\n"
	d += "skin_height: " + str(_header.skin_height) + "\n"
	d += "num_verts: " + str(_header.num_vertices) + "\n"
	d += "num_tris: " + str(_header.num_tris) + "\n"
	d += "num_frames: " + str(_header.num_frames) + "\n"
	#d += "sync_type: " + str(_header.sync_type) + "\n"
	#d += "flags: " + str(_header.flags) + "\n"
	d += "frame_size : " + str(_header.frame_size) + "\n"
	d += "frames...\n"
	for f in range(_header.num_frames):
		d += str(f) + ":"
		d += _frames[f].name
		d += " "
	d += "\n"
	return d

#----------

#func get_image_from_skin(skin):
#	print("* get_image_from_skin")
#	var img = Image.new()
#	var w = _header.skin_width
#	var h = _header.skin_height
#	var sd = _skins[skin].data
#	img.create(w,h,false,Image.FORMAT_RGBA8)
#	img.lock()
#	for y in range(h):
#		for x in range(w):
#			var i = y * w + x
#			var c = sd[i]
#			var col = Color( md2_quake_palette[c] )
#			img.set_pixel(x,y,col)
#	img.unlock()
#	return img
	
#----------

#func get_image_from_all_skins():
#	print("* get_image_from_all_skins")
#	var img = Image.new()
#	var w = _header.skin_width
#	var h = _header.skin_height
#	var sh = h * _header.num_skins
#	img.create(w,sh,false,Image.FORMAT_RGBA8)
#	img.lock()
#	for s in range(_header.num_skins):
#		var sd = _skins[s].data
#		for y in range(h):
#			for x in range(w):
#				var i = y * w + x
#				var c = sd[i]
#				var col = Color( md2_quake_palette[c] )
#				img.set_pixel(x,(s*h)+y,col)
#	img.unlock()
#	return img

#----------

# we do the (x,y,z -> x,z,-y) transformation in the vertex shader

func get_image_from_vertices():
	#print("* get_image_from_vertices")
	var image = Image.new()
	var w = _header.num_tris * 3
	var h = _header.num_frames
	image.create(w,h,false,Image.FORMAT_RGBAF)
	image.lock()
	for y in range(_header.num_frames):
		var frame = _frames[y]
		for x in range(_header.num_tris):
			var i1 = _triangles[x].v1;
			var i2 = _triangles[x].v2;
			var i3 = _triangles[x].v3;
			var v1 = frame.verts[i1].pos / 255.0
			var v2 = frame.verts[i2].pos / 255.0
			var v3 = frame.verts[i3].pos / 255.0
			#var c1 = Color( v1.x, v1.y, v1.z, 1.0 )
			#var c2 = Color( v2.x, v2.y, v2.z, 1.0 )
			#var c3 = Color( v3.x, v3.y, v3.z, 1.0 )
			#image.set_pixel((x*3)  ,y,c1)
			#image.set_pixel((x*3)+1,y,c2)
			#image.set_pixel((x*3)+2,y,c3)
			set_vector(image,(x*3)  ,y,v1)
			set_vector(image,(x*3)+1,y,v2)
			set_vector(image,(x*3)+2,y,v3)
	image.unlock()
	return image

#----------

func get_image_from_normals():
	#print("* get_image_from_normals")
	var image = Image.new()
	var w = _header.num_tris * 3
	var h = _header.num_frames
	image.create(w,h,false,Image.FORMAT_RGBAF)
	image.lock()
	for y in range(_header.num_frames):
		var normals = calc_vertex_normals(y)
		#var frame = _frames[y]
		for x in range(_header.num_tris):
			var i1 = _triangles[x].v1;
			var i2 = _triangles[x].v2;
			var i3 = _triangles[x].v3;
			var n1 = normals[i1]
			var n2 = normals[i2]
			var n3 = normals[i3]
			#n1 = (n1 * 0.5) + Vector3(0.5,0.5,0.5)
			#n2 = (n2 * 0.5) + Vector3(0.5,0.5,0.5)
			#n3 = (n3 * 0.5) + Vector3(0.5,0.5,0.5)
			#var c1 = Color( n1.x, n1.y, n1.z, 1.0 )
			#var c2 = Color( n2.x, n2.y, n2.z, 1.0 )
			#var c3 = Color( n3.x, n3.y, n3.z, 1.0 )
			#image.set_pixel((x*3)  ,y,c1)
			#image.set_pixel((x*3)+1,y,c2)
			#image.set_pixel((x*3)+2,y,c3)
			set_vector_signed(image,(x*3)  ,y,n1)
			set_vector_signed(image,(x*3)+1,y,n2)
			set_vector_signed(image,(x*3)+2,y,n3)
	image.unlock()
	return image

#----------

const data_image_count = 16

func get_image_from_frame_data():
	#print("* get_image_from_normals")
	var image = Image.new()
	image.create(data_image_count,_header.num_frames,false,Image.FORMAT_RGBAF)
	image.lock()
	for fr in range(_header.num_frames):
		var scale = _frames[fr].scale
		var translate = _frames[fr].translate
		set_vector(image,0,fr,scale)
		set_vector2(image,1,fr,translate)
	image.unlock()
	return image

#----------

func get_texture_from_image(image):
	#print("* get_texture_from_image")
	var texture = ImageTexture.new()
	texture.create_from_image(image,0)
	texture.flags = 0
	return texture

#----------

func get_texture_from_file(name):
	var basename = name.get_basename()	
	#basename.to_lower()
	#print("* get_texture_from_image")
	var image = Image.new()
	
	var path =  _path + "/" + basename + ".png"
	print("path: " + path)
	
	var f = File.new()
	if f.file_exists(path):
		image.load(path)
	
	image.load(path)
	#var image = load(path)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	texture.flags = 0
	return texture


#----------

#func get_texture_from_skin(skin):
#	print("* get_texture from skin")
#	var image = get_image_from_skin(skin)
#	var texture = ImageTexture.new()
#	texture.create_from_image(image,0)
#	texture.flags = 0
#	return texture

#----------

#func get_texture_from_all_skins():
#	print("* get_texture_from_all_skins")
#	var image = get_image_from_all_skins()
#	var texture = ImageTexture.new()
#	texture.create_from_image(image,0)
#	texture.flags = 0
#	return texture

#----------

func get_shader():
	#print("* get_shader")
	#var sha = Shader.new()
	#sha.code = mdl_shader
	var shader = load("res://addons/md2_importer/md2.shader")
	return shader

#----------

func get_material(skin):
	#print("* get_material")
	var material = ShaderMaterial.new()
#	var skin_img = get_image_from_all_skins()
	var vert_img = get_image_from_vertices()
	var norm_img = get_image_from_normals()
	var frame_data_img = get_image_from_frame_data()
	
#	var skin_tex = get_texture_from_image(skin_img)
	var skin_tex = get_texture_from_file( _skins[skin].name )
	var vert_tex = get_texture_from_image(vert_img)
	var norm_tex = get_texture_from_image(norm_img)
	var frame_data_tex = get_texture_from_image(frame_data_img)
	
	var shader = get_shader()
	material.shader = shader
#	material.set_shader_param("_scale",_header.scale)
#	material.set_shader_param("_translate",(_header.translate))
	#material.set_shader_param("_size",mdl_size)
	material.set_shader_param("_start_frame",0)
	material.set_shader_param("_end_frame",_header.num_frames - 1)
	material.set_shader_param("_interpolate",true)
	material.set_shader_param("_wraparound",true)
	if _header.num_frames > 0:
		material.set_shader_param("_automate",true)
	else:
		material.set_shader_param("_automate",false)
	material.set_shader_param("_fps",5.0)
	material.set_shader_param("_anim_offset",0.0)
	material.set_shader_param("_num_skins",1) # _header.num_skins)
	material.set_shader_param("_skin_index",0)
	material.set_shader_param("_skin_texture",skin_tex)
	material.set_shader_param("_vertex_texture",vert_tex)
	material.set_shader_param("_normal_texture",norm_tex)
	material.set_shader_param("_frame_data_texture",frame_data_tex)
	#material.albedo_texture = stex
	return material

#----------

func get_array_mesh(frame):
	#print("* get_array_mesh")
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = get_vertex_array(frame)
	arrays[ArrayMesh.ARRAY_NORMAL] = get_normal_array(frame)
	arrays[ArrayMesh.ARRAY_COLOR] = get_color_array()
	arrays[ArrayMesh.ARRAY_TEX_UV] = get_texcoord1_array()
	arrays[ArrayMesh.ARRAY_TEX_UV2] = get_texcoord2_array()
	arrays[ArrayMesh.ARRAY_INDEX] = get_triangle_array()
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	#var material = SpatialMaterial.new()
	#array_mesh.surface_set_material(0,material)
	return array_mesh

#----------

func get_mesh_instance(frame,skin):
	#print("* get_mesh_instance")
	var material = get_material(skin)
	var mesh = get_array_mesh(frame)
	#mesh.surface_set_name(0,"mdl shader")
	#mesh.surface_set_material(0,material)
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = mesh
	mesh_instance.set_surface_material(0,material)
	#mesh_instance.rotation.x = -PI / 2.0	
	#mesh_instance.extra_cull_margin = 1.0
	mesh_instance.editor_description = get_description()
	return mesh_instance

#----------

func get_scene(name,path,frame,skin):
	_path = path
	#print("path: " + path)
	#print("* get_scene")
	var mesh_instance = get_mesh_instance(frame,skin)
	var scene = PackedScene.new()
	scene.pack(mesh_instance)
	return scene
