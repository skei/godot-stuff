tool
extends EditorImportPlugin

#----------------------------------------------------------------------

enum Presets { DEFAULT }
const INV_255 = (1.0 / 255.0)

#----------

var file = null
var mdl = mdl_header.new()
var _skins = Array()
var _texcoords = Array()
var _triangles = Array()
var _frames = Array()

#----------------------------------------------------------------------

func get_importer_name():
	return "mdl_importer"

#----------

func get_visible_name():
	return "mdl"

#----------

func get_recognized_extensions():
	return ["mdl"]

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

#----------

#func load(path,original_path):
#	print("load: " + path + " / " + original_path)
#	read(path)
#	var mesh = get_array_mesh(0)
#	var material = get_material(0)
#	mesh.surface_set_name(0,"material_name")
#	mesh.surface_set_material(0,material)
#	return mesh

func import(source_file, save_path, options, r_platform_variants, r_gen_files):
	read(source_file,options.palette)
	var name = source_file.get_basename()
	#var scene = get_scene(name,options.frame,options.skin)
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

class mdl_header:
	var identifier						# magic number: "IDPO"
	var version							# version: 6
	var scale			= Vector3()		# scale factor
	var translate		= Vector3()		# translation vector
	var bounding_radius					#
	var eye_position	= Vector3()		# eyes' position
	var num_skins						# number of textures
	var	skin_width						# texture width
	var skin_height						# texture height
	var num_verts						# number of vertices
	var num_tris						# number of triangles
	var num_frames						# number of frames
	var sync_type						# 0 = synchron, 1 = random
	var flags							# state flag
	var size							#

class mdl_skin:
	var group				# 0 = single, 1 = group
	var data				# texture data

class mdl_groupskin:
	var group				# 1 = group
	var nb					# number of pics
	var time				# time duration for each pic
	var data				# texture data

class mdl_texcoord:
	var on_seam				#
	var uv = Vector2()		#

class mdl_triangle:
	var front_facing		# 0 = backface, 1 = frontface
	var v1					# vertex indices
	var v2					#
	var v3					#

class mdl_vertex:
	var pos = Vector3()		#
	var normal				#

class mdl_simpleframe:
	var type				# 0 = simple
	var bboxmin				# bounding box min
	var bboxmax				# bounding box max
	var name = String()		# char name[16]
	var verts				# vertex list of the frame

class mdl_framegroup:
	var type				# !0 = group
	var min_				# min pos in all simple frames
	var max_				# max pos in all simple frames
	var time = Array()		# time duration for each frame
	var frames = Array()	# simple frame list

#----------------------------------------------------------------------

const mdl_quake_palette = [
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

# hexen 2:
# https://github.com/victorfeitosa/quake-hexen2-mdl-export-import/blob/master/hexen2pal.py

const mdl_hexen_palette = [
	"#00000000","#000000","#080808","#101010","#181818","#202020","#282828","#303030",
	"#383838","#404040","#484848","#505050","#545454","#585858","#606060","#686868",
	"#707070","#787878","#808080","#888888","#949494","#9C9C9C","#A8A8A8","#B4B4B4",
	"#B8B8B8","#C4C4C4","#CCCCCC","#D4D4D4","#E0E0E0","#E8E8E8","#F0F0F0","#FCFCFC",
	"#08080C","#101014","#18181C","#1C2024","#24242C","#2C2C34","#30343C","#383844",
	"#404048","#4C4C58","#5C5C68","#6C7080","#808498","#989CB0","#A8ACC4","#BCC4DC",
	"#201814","#28201C","#302420","#342C28","#3C342C","#443834","#4C4038","#544840",
	"#5C4C48","#64544C","#6C5C54","#706058","#786860","#807064","#88746C","#907C70",
	"#141814","#1C201C","#202420","#282C28","#2C302C","#303830","#384038","#404440",
	"#444C44","#545C54","#687068","#788078","#8C9488","#9CA498","#ACB4A8","#BCC4B8",
	"#302008","#3C2808","#483010","#543814","#5C401C","#644824","#6C502C","#785C34",
	"#88683C","#947448","#A08054","#A8885C","#B49064","#BC986C","#C4A074","#CCA87C",
	"#101410","#141C14","#182018","#1C241C","#202C20","#243024","#283828","#2C3C2C",
	"#304430","#344C34","#3C543C","#445C40","#4C6448","#546C4C","#5C7454","#64805C",
	"#180C08","#201008","#281408","#34180C","#3C1C0C","#44200C","#4C2410","#542C14",
	"#5C3018","#64381C","#704020","#784824","#80502C","#905C38","#A87048","#C08458",
	"#180404","#240404","#300000","#3C0000","#440000","#500000","#580000","#640000",
	"#700000","#840000","#980000","#AC0000","#C00000","#D40000","#E80000","#FC0000",
	"#100C20","#1C1430","#201C38","#282444","#342C50","#3C385C","#444068","#504874",
	"#585480","#64608C","#6C6C98","#7874A4","#8484B0","#9090BC","#9C9CC8","#ACACD4",
	"#241404","#341804","#442004","#502800","#643004","#7C3C04","#8C4804","#9C5808",
	"#AC6408","#BC740C","#CC800C","#DC9010","#ECA014","#FCB838","#F8C850","#F8DC78",
	"#141004","#1C1808","#242008","#2C280C","#343010","#383810","#404014","#444818",
	"#48501C","#505C20","#546828","#58742C","#5C8034","#5C8C34","#5C9438","#60A040",
	"#3C1010","#481818","#541C1C","#642424","#702C2C","#7C3430","#8C4038","#984C40",
	"#2C1408","#381C0C","#482010","#542814","#602C1C","#703420","#7C3828","#8C4030",
	"#181410","#241C14","#2C241C","#382C20","#403424","#483C2C","#504430","#5C4C34",
	"#64543C","#705C44","#786448","#847050","#907858","#988060","#A08868","#A89470",
	"#24180C","#2C2010","#342814","#3C2C14","#483418","#503C1C","#58441C","#684C20",
	"#946038","#A06C40","#AC7448","#B47C50","#C08458","#CC8C5C","#D89C6C","#3C145C",
	"#642474","#A848A4","#CC6CC0","#045404","#048404","#00B400","#00D800","#040490",
	"#1044CC","#2484E0","#58A8E8","#D80404","#F44800","#FC8000","#FCAC18","#FCFCFC"
]

var mdl_palette

#----------

#const mdl_normals = [
#	Vector3(-0.525731,  0.000000,  0.850651),
#	Vector3(-0.442863,  0.238856,  0.864188),
#	Vector3(-0.295242,  0.000000,  0.955423),
#	Vector3(-0.309017,  0.500000,  0.809017),
#	Vector3(-0.162460,  0.262866,  0.951056),
#	Vector3( 0.000000,  0.000000,  1.000000),
#	Vector3( 0.000000,  0.850651,  0.525731),
#	Vector3(-0.147621,  0.716567,  0.681718),
#	Vector3( 0.147621,  0.716567,  0.681718),
#	Vector3( 0.000000,  0.525731,  0.850651),
#	Vector3( 0.309017,  0.500000,  0.809017),
#	Vector3( 0.525731,  0.000000,  0.850651),
#	Vector3( 0.295242,  0.000000,  0.955423),
#	Vector3( 0.442863,  0.238856,  0.864188),
#	Vector3( 0.162460,  0.262866,  0.951056),
#	Vector3(-0.681718,  0.147621,  0.716567),
#	Vector3(-0.809017,  0.309017,  0.500000),
#	Vector3(-0.587785,  0.425325,  0.688191),
#	Vector3(-0.850651,  0.525731,  0.000000),
#	Vector3(-0.864188,  0.442863,  0.238856),
#	Vector3(-0.716567,  0.681718,  0.147621),
#	Vector3(-0.688191,  0.587785,  0.425325),
#	Vector3(-0.500000,  0.809017,  0.309017),
#	Vector3(-0.238856,  0.864188,  0.442863),
#	Vector3(-0.425325,  0.688191,  0.587785),
#	Vector3(-0.716567,  0.681718, -0.147621),
#	Vector3(-0.500000,  0.809017, -0.309017),
#	Vector3(-0.525731,  0.850651,  0.000000),
#	Vector3( 0.000000,  0.850651, -0.525731),
#	Vector3(-0.238856,  0.864188, -0.442863),
#	Vector3( 0.000000,  0.955423, -0.295242),
#	Vector3(-0.262866,  0.951056, -0.162460),
#	Vector3( 0.000000,  1.000000,  0.000000),
#	Vector3( 0.000000,  0.955423,  0.295242),
#	Vector3(-0.262866,  0.951056,  0.162460),
#	Vector3( 0.238856,  0.864188,  0.442863),
#	Vector3( 0.262866,  0.951056,  0.162460),
#	Vector3( 0.500000,  0.809017,  0.309017),
#	Vector3( 0.238856,  0.864188, -0.442863),
#	Vector3( 0.262866,  0.951056, -0.162460),
#	Vector3( 0.500000,  0.809017, -0.309017),
#	Vector3( 0.850651,  0.525731,  0.000000),
#	Vector3( 0.716567,  0.681718,  0.147621),
#	Vector3( 0.716567,  0.681718, -0.147621),
#	Vector3( 0.525731,  0.850651,  0.000000),
#	Vector3( 0.425325,  0.688191,  0.587785),
#	Vector3( 0.864188,  0.442863,  0.238856),
#	Vector3( 0.688191,  0.587785,  0.425325),
#	Vector3( 0.809017,  0.309017,  0.500000),
#	Vector3( 0.681718,  0.147621,  0.716567),
#	Vector3( 0.587785,  0.425325,  0.688191),
#	Vector3( 0.955423,  0.295242,  0.000000),
#	Vector3( 1.000000,  0.000000,  0.000000),
#	Vector3( 0.951056,  0.162460,  0.262866),
#	Vector3( 0.850651, -0.525731,  0.000000),
#	Vector3( 0.955423, -0.295242,  0.000000),
#	Vector3( 0.864188, -0.442863,  0.238856),
#	Vector3( 0.951056, -0.162460,  0.262866),
#	Vector3( 0.809017, -0.309017,  0.500000),
#	Vector3( 0.681718, -0.147621,  0.716567),
#	Vector3( 0.850651,  0.000000,  0.525731),
#	Vector3( 0.864188,  0.442863, -0.238856),
#	Vector3( 0.809017,  0.309017, -0.500000),
#	Vector3( 0.951056,  0.162460, -0.262866),
#	Vector3( 0.525731,  0.000000, -0.850651),
#	Vector3( 0.681718,  0.147621, -0.716567),
#	Vector3( 0.681718, -0.147621, -0.716567),
#	Vector3( 0.850651,  0.000000, -0.525731),
#	Vector3( 0.809017, -0.309017, -0.500000),
#	Vector3( 0.864188, -0.442863, -0.238856),
#	Vector3( 0.951056, -0.162460, -0.262866),
#	Vector3( 0.147621,  0.716567, -0.681718),
#	Vector3( 0.309017,  0.500000, -0.809017),
#	Vector3( 0.425325,  0.688191, -0.587785),
#	Vector3( 0.442863,  0.238856, -0.864188),
#	Vector3( 0.587785,  0.425325, -0.688191),
#	Vector3( 0.688191,  0.587785, -0.425325),
#	Vector3(-0.147621,  0.716567, -0.681718),
#	Vector3(-0.309017,  0.500000, -0.809017),
#	Vector3( 0.000000,  0.525731, -0.850651),
#	Vector3(-0.525731,  0.000000, -0.850651),
#	Vector3(-0.442863,  0.238856, -0.864188),
#	Vector3(-0.295242,  0.000000, -0.955423),
#	Vector3(-0.162460,  0.262866, -0.951056),
#	Vector3( 0.000000,  0.000000, -1.000000),
#	Vector3( 0.295242,  0.000000, -0.955423),
#	Vector3( 0.162460,  0.262866, -0.951056),
#	Vector3(-0.442863, -0.238856, -0.864188),
#	Vector3(-0.309017, -0.500000, -0.809017),
#	Vector3(-0.162460, -0.262866, -0.951056),
#	Vector3( 0.000000, -0.850651, -0.525731),
#	Vector3(-0.147621, -0.716567, -0.681718),
#	Vector3( 0.147621, -0.716567, -0.681718),
#	Vector3( 0.000000, -0.525731, -0.850651),
#	Vector3( 0.309017, -0.500000, -0.809017),
#	Vector3( 0.442863, -0.238856, -0.864188),
#	Vector3( 0.162460, -0.262866, -0.951056),
#	Vector3( 0.238856, -0.864188, -0.442863),
#	Vector3( 0.500000, -0.809017, -0.309017),
#	Vector3( 0.425325, -0.688191, -0.587785),
#	Vector3( 0.716567, -0.681718, -0.147621),
#	Vector3( 0.688191, -0.587785, -0.425325),
#	Vector3( 0.587785, -0.425325, -0.688191),
#	Vector3( 0.000000, -0.955423, -0.295242),
#	Vector3( 0.000000, -1.000000,  0.000000),
#	Vector3( 0.262866, -0.951056, -0.162460),
#	Vector3( 0.000000, -0.850651,  0.525731),
#	Vector3( 0.000000, -0.955423,  0.295242),
#	Vector3( 0.238856, -0.864188,  0.442863),
#	Vector3( 0.262866, -0.951056,  0.162460),
#	Vector3( 0.500000, -0.809017,  0.309017),
#	Vector3( 0.716567, -0.681718,  0.147621),
#	Vector3( 0.525731, -0.850651,  0.000000),
#	Vector3(-0.238856, -0.864188, -0.442863),
#	Vector3(-0.500000, -0.809017, -0.309017),
#	Vector3(-0.262866, -0.951056, -0.162460),
#	Vector3(-0.850651, -0.525731,  0.000000),
#	Vector3(-0.716567, -0.681718, -0.147621),
#	Vector3(-0.716567, -0.681718,  0.147621),
#	Vector3(-0.525731, -0.850651,  0.000000),
#	Vector3(-0.500000, -0.809017,  0.309017),
#	Vector3(-0.238856, -0.864188,  0.442863),
#	Vector3(-0.262866, -0.951056,  0.162460),
#	Vector3(-0.864188, -0.442863,  0.238856),
#	Vector3(-0.809017, -0.309017,  0.500000),
#	Vector3(-0.688191, -0.587785,  0.425325),
#	Vector3(-0.681718, -0.147621,  0.716567),
#	Vector3(-0.442863, -0.238856,  0.864188),
#	Vector3(-0.587785, -0.425325,  0.688191),
#	Vector3(-0.309017, -0.500000,  0.809017),
#	Vector3(-0.147621, -0.716567,  0.681718),
#	Vector3(-0.425325, -0.688191,  0.587785),
#	Vector3(-0.162460, -0.262866,  0.951056),
#	Vector3( 0.442863, -0.238856,  0.864188),
#	Vector3( 0.162460, -0.262866,  0.951056),
#	Vector3( 0.309017, -0.500000,  0.809017),
#	Vector3( 0.147621, -0.716567,  0.681718),
#	Vector3( 0.000000, -0.525731,  0.850651),
#	Vector3( 0.425325, -0.688191,  0.587785),
#	Vector3( 0.587785, -0.425325,  0.688191),
#	Vector3( 0.688191, -0.587785,  0.425325),
#	Vector3(-0.955423,  0.295242,  0.000000),
#	Vector3(-0.951056,  0.162460,  0.262866),
#	Vector3(-1.000000,  0.000000,  0.000000),
#	Vector3(-0.850651,  0.000000,  0.525731),
#	Vector3(-0.955423, -0.295242,  0.000000),
#	Vector3(-0.951056, -0.162460,  0.262866),
#	Vector3(-0.864188,  0.442863, -0.238856),
#	Vector3(-0.951056,  0.162460, -0.262866),
#	Vector3(-0.809017,  0.309017, -0.500000),
#	Vector3(-0.864188, -0.442863, -0.238856),
#	Vector3(-0.951056, -0.162460, -0.262866),
#	Vector3(-0.809017, -0.309017, -0.500000),
#	Vector3(-0.681718,  0.147621, -0.716567),
#	Vector3(-0.681718, -0.147621, -0.716567),
#	Vector3(-0.850651,  0.000000, -0.525731),
#	Vector3(-0.688191,  0.587785, -0.425325),
#	Vector3(-0.587785,  0.425325, -0.688191),
#	Vector3(-0.425325,  0.688191, -0.587785),
#	Vector3(-0.425325, -0.688191, -0.587785),
#	Vector3(-0.587785, -0.425325, -0.688191),
#	Vector3(-0.688191, -0.587785, -0.425325)
#]

#----------------------------------------------------------------------
#
#----------------------------------------------------------------------

#func read(filename):
#	reset()
#	_file = File.new()
#	if not _file.file_exists(filename):
#		print("ERROR: file '" + filename + "' does not exist")
#		return ERR_FILE_NOT_FOUND
#	_file.open(filename,File.READ)
#	read_header()
#	print_header()
#	read_skins()
#	read_texcoords()
#	read_triangles()
#	read_glcmds()
#	read_frames()
#	_file.close()
#	return OK

func read(filename,palette):
	print("palette: " + palette)
	if palette == "hexen":
		mdl_palette = mdl_hexen_palette
	else: #palette == "quake":
		mdl_palette = mdl_quake_palette
	file = File.new()
	if not file.file_exists(filename):
		print("ERROR: file '" + filename + "' does not exist")
		return ERR_FILE_NOT_FOUND
	file.open(filename,File.READ)
	read_header()
	_skins = read_skins()
	_texcoords = read_texcoords()
	_triangles = read_triangles()
	_frames = read_frames()
	file.close()
	return OK

#----------------------------------------------------------------------

# x,y,z -> x,z,-y

func get_vertex_array(fr):
	var vertices = PoolVector3Array()
	for i in range(mdl.num_tris):
		var i1 = _triangles[i].v1;
		var i2 = _triangles[i].v2;
		var i3 = _triangles[i].v3;
		var v1 = _frames[fr].verts[i1].pos / 255.0
		var v2 = _frames[fr].verts[i2].pos / 255.0
		var v3 = _frames[fr].verts[i3].pos / 255.0
		
		v1 = ((v1 * mdl.scale) + mdl.translate)
		v2 = ((v2 * mdl.scale) + mdl.translate)
		v3 = ((v3 * mdl.scale) + mdl.translate)
		
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
		
		vertices.push_back(v1 * 5.0)
		vertices.push_back(v2 * 5.0)
		vertices.push_back(v3 * 5.0)
		
	return vertices

#----------

func get_normal_array(frame):
	var normals = PoolVector3Array()
	var vn = calc_vertex_normals(frame)
	for i in range(mdl.num_tris):
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
	for i in range(mdl.num_tris):
		var c1 = Color(1,0,0)
		var c2 = Color(0,1,0)
		var c3 = Color(0,0,1)
		colors.push_back(c1)
		colors.push_back(c2)
		colors.push_back(c3)
	return colors

#----------

func get_texcoord1_array():
	var skin_size = Vector2(mdl.skin_width,mdl.skin_height)
	var texcoords = PoolVector2Array()
	for i in range(mdl.num_tris):
		var i1 = _triangles[i].v1;
		var i2 = _triangles[i].v2;
		var i3 = _triangles[i].v3;
		var uv1 = _texcoords[i1].uv / skin_size;
		var uv2 = _texcoords[i2].uv / skin_size;
		var uv3 = _texcoords[i3].uv / skin_size;
		if _triangles[i].front_facing == 0:
			if _texcoords[i1].on_seam > 0:
				uv1.x += 0.5;
			if _texcoords[i2].on_seam > 0:
				uv2.x += 0.5;
			if _texcoords[i3].on_seam > 0:
				uv3.x += 0.5;
		texcoords.push_back(uv1)
		texcoords.push_back(uv2)
		texcoords.push_back(uv3)
	return texcoords

#----------

func get_texcoord2_array():
	var texcoords = PoolVector2Array()
	for i in range(mdl.num_tris):
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
	for i in range(mdl.num_tris):
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
	var d = ""
	d += "scale:" + str(mdl.scale.x) + "," + str(mdl.scale.y) + "," + str(mdl.scale.z) + "\n"
	d += "translate:" + str(mdl.translate.x) + "," + str(mdl.translate.y) + "," + str(mdl.translate.z) + "\n"
	d += "bounding_radius : " + str(mdl.bounding_radius) + "\n"
	d += "eye_position:" + str(mdl.eye_position.x) + "," + str(mdl.eye_position.y) + "," + str(mdl.eye_position.z) + "\n"
	d += "num_skins : " + str(mdl.num_skins) + "\n"
	d += "skin_width: " + str(mdl.skin_width) + "\n"
	d += "skin_height: " + str(mdl.skin_height) + "\n"
	d += "num_verts: " + str(mdl.num_verts) + "\n"
	d += "num_tris: " + str(mdl.num_tris) + "\n"
	d += "num_frames: " + str(mdl.num_frames) + "\n"
	d += "sync_type: " + str(mdl.sync_type) + "\n"
	d += "flags: " + str(mdl.flags) + "\n"
	d += "size : " + str(mdl.size) + "\n"
	d += "frames...\n"
	for f in range(mdl.num_frames):
		d += str(f) + ":"
		d += _frames[f].name
		d += " "
	d += "\n"
	return d

#----------

func get_image_from_skin(skin):
	var image = Image.new()
	var w = mdl.skin_width
	var h = mdl.skin_height
	var sd = _skins[skin].data
	image.create(w,h,false,Image.FORMAT_RGBA8)
	image.lock()
	for y in range(h):
		for x in range(w):
			var i = y * w + x
			var c = sd[i]
			var col = Color( mdl_palette[c] )
			image.set_pixel(x,y,col)
	image.unlock()
	return image

#----------

func get_image_from_all_skins():
	var image = Image.new()
	var w = mdl.skin_width
	var h = mdl.skin_height
	var sh = h * mdl.num_skins
	image.create(w,sh,false,Image.FORMAT_RGBA8)
	image.lock()
	for s in range(mdl.num_skins):
		var sd = _skins[s].data
		for y in range(h):
			for x in range(w):
				var i = y * w + x
				var c = sd[i]
				var col = Color( mdl_palette[c] )
				image.set_pixel(x,(s*h)+y,col)
	image.unlock()
	return image

#----------

# we do the (x,y,z -> x,z,-y) transformation in the vertex shader

func get_image_from_vertices():
	var image = Image.new()
	var w = mdl.num_tris * 3
	var h = mdl.num_frames
	image.create(w,h,false,Image.FORMAT_RGBAF)
	image.lock()
	for y in range(mdl.num_frames):
		var frame = _frames[y]
		for x in range(mdl.num_tris):
			var i1 = _triangles[x].v1;
			var i2 = _triangles[x].v2;
			var i3 = _triangles[x].v3;
			var v1 = frame.verts[i1].pos / 255.0
			var v2 = frame.verts[i2].pos / 255.0
			var v3 = frame.verts[i3].pos / 255.0
			var c1 = Color( v1.x, v1.y, v1.z, 1.0 )
			var c2 = Color( v2.x, v2.y, v2.z, 1.0 )
			var c3 = Color( v3.x, v3.y, v3.z, 1.0 )
			image.set_pixel((x*3)  ,y,c1)
			image.set_pixel((x*3)+1,y,c2)
			image.set_pixel((x*3)+2,y,c3)
	image.unlock()
	return image

#----------

func get_image_from_normals():
	var image = Image.new()
	var w = mdl.num_tris * 3
	var h = mdl.num_frames
	image.create(w,h,false,Image.FORMAT_RGBAF)
	image.lock()
	for y in range(mdl.num_frames):
		var normals = calc_vertex_normals(y)
		var frame = _frames[y]
		for x in range(mdl.num_tris):
			var i1 = _triangles[x].v1;
			var i2 = _triangles[x].v2;
			var i3 = _triangles[x].v3;
			var n1 = normals[i1]
			var n2 = normals[i2]
			var n3 = normals[i3]
			n1 = (n1 * 0.5) + Vector3(0.5,0.5,0.5)
			n2 = (n2 * 0.5) + Vector3(0.5,0.5,0.5)
			n3 = (n3 * 0.5) + Vector3(0.5,0.5,0.5)
			var c1 = Color( n1.x, n1.y, n1.z, 1.0 )
			var c2 = Color( n2.x, n2.y, n2.z, 1.0 )
			var c3 = Color( n3.x, n3.y, n3.z, 1.0 )
			image.set_pixel((x*3)  ,y,c1)
			image.set_pixel((x*3)+1,y,c2)
			image.set_pixel((x*3)+2,y,c3)
	image.unlock()
	return image

#----------

func get_texture_from_image(image):
	var texture = ImageTexture.new()
	texture.create_from_image(image,0)
	texture.flags = 0
	return texture

#----------

func get_texture_from_skin(skin):
	var image = get_image_from_skin(skin)
	var texture = ImageTexture.new()
	texture.create_from_image(image,0)
	texture.flags = 0
	return texture

#----------

func get_texture_from_all_skins():
	var image = get_image_from_all_skins()
	var texture = ImageTexture.new()
	texture.create_from_image(image,0)
	texture.flags = 0
	return texture

#----------

func get_shader():
	#var sha = Shader.new()
	#sha.code = mdl_shader
	var shader = load("res://addons/mdl_importer/mdl.shader")
	return shader

#----------

func get_material(skin):
#	var mat = SpatialMaterial.new()
	var material = ShaderMaterial.new()
	#var simg = create_image_from_skin(skin)
	var skin_img = get_image_from_all_skins()
	var vert_img = get_image_from_vertices()
	var norm_img = get_image_from_normals()
	var skin_tex = get_texture_from_image(skin_img)
	var vert_tex = get_texture_from_image(vert_img)
	var norm_tex = get_texture_from_image(norm_img)
	var shader = get_shader()
	material.shader = shader
	material.set_shader_param("scale",mdl.scale)
	material.set_shader_param("translate",(mdl.translate))
	#material.set_shader_param("size",mdl_size)
	material.set_shader_param("start_frame",0)
	material.set_shader_param("end_frame",mdl.num_frames - 1)
	material.set_shader_param("interpolate",true)
	material.set_shader_param("wraparound",true)
	if mdl.num_frames > 0:
		material.set_shader_param("automate",true)
	else:
		material.set_shader_param("automate",false)
	material.set_shader_param("fps",10.0)
	material.set_shader_param("anim_offset",0.0)
	material.set_shader_param("num_skins",mdl.num_skins)
	material.set_shader_param("skin_index",0)
	material.set_shader_param("skin_texture",skin_tex)
	material.set_shader_param("vertex_texture",vert_tex)
	material.set_shader_param("normal_texture",norm_tex)
	#material.albedo_texture = stex
	return material

#----------

func get_array_mesh(frame):
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

func get_scene(name,frame,skin):
	var mesh_instance = get_mesh_instance(frame,skin)
	var scene = PackedScene.new()
	scene.pack(mesh_instance)
	return scene

#----------------------------------------------------------------------
#
#----------------------------------------------------------------------

func calc_vertex_normals(fr):
	var vertices = _frames[fr].verts
	#var tri_normals = calc_tri_normals(frame)
	var vert_normals = []
	vert_normals.resize(mdl.num_verts)
	for v in range(mdl.num_verts):
		vert_normals[v] = Vector3()
	for t in range(mdl.num_tris):
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
	for v in range(mdl.num_verts):
		vert_normals[v] = vert_normals[v].normalized()
	return vert_normals

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

func read_header():
	mdl.identifier = read_int()
	if mdl.identifier != 1330660425:
		print("ERROR: wrong mdl.identifier " + str(mdl.identifier) + " (should be 1330660425)")
		return ERR_FILE_CORRUPT
	mdl.version = read_int()
	if mdl.version != 6:
		print("ERROR: wrong header.version " + str(mdl.version) + " (should be 6)")
		return ERR_FILE_UNRECOGNIZED
	mdl.scale = read_vector()
	mdl.translate = read_vector() * INV_255
	mdl.bounding_radius = read_float() * INV_255
	mdl.eye_position = read_vector() * INV_255
	mdl.num_skins = read_int()
	mdl.skin_width = read_int()
	mdl.skin_height = read_int()
	mdl.num_verts = read_int()
	mdl.num_tris = read_int()
	mdl.num_frames = read_int()
	mdl.sync_type = read_int()
	mdl.flags = read_int()
	mdl.size = read_float()
	return OK

#----------------------------------------------------------------------
#
#----------------------------------------------------------------------

func read_byte():
	return file.get_8()

#----------

func read_int():
	return file.get_32()

#----------

func read_float():
	return file.get_float()

#----------

func read_vector():
	var x = file.get_float()
	var y = file.get_float()
	var z = file.get_float()
	var v = Vector3(x,y,z)
	return v

func read_vector8():
	var x = file.get_8()
	var y = file.get_8()
	var z = file.get_8()
	var v = Vector3(x,y,z)
	return v

#----------

func read_string():
	var zero = false
	var s = String()
	for i in range(16):
		var c = file.get_8()
		if c == 0:
			zero = true
		if not zero:
			s += String("%c" % c)
	return s

#----------

func read_byte_buffer(size):
	var b = file.get_buffer(size)
	return b

#----------

func read_float_buffer(size):
	var data = file.get_buffer(size * 4)
	return data

#----------------------------------------------------------------------
#
#----------------------------------------------------------------------

func read_vertex():
	var vertex = mdl_vertex.new()
	vertex.pos = read_vector8()
	vertex.normal = read_byte()
	return vertex

#----------

func read_vertices():
	var vertices = Array()
	for i in range(mdl.num_verts):
		var vertex = read_vertex()
		vertices.append(vertex)
	return vertices

#----------

func read_texcoord():
	var texcoord = mdl_texcoord.new()
	texcoord.on_seam = file.get_32()
	var s = file.get_32()
	var t = file.get_32()
	texcoord.uv = Vector2(s,t)
	return texcoord

#----------

func read_texcoords():
	var texcoords = Array()
	for i in range(mdl.num_verts):
		var texcoord = read_texcoord()
		texcoords.append(texcoord)
	return texcoords

#----------

func read_triangle():
	var triangle = mdl_triangle.new()
	triangle.front_facing = file.get_32() # == 1
	triangle.v1 = file.get_32()
	triangle.v2 = file.get_32()
	triangle.v3 = file.get_32()
	return triangle

#----------

func read_triangles():
	var triangles = Array()
	for i in range(mdl.num_tris):
		var triangle = read_triangle()
		triangles.append(triangle)
	return triangles

#----------

func read_skin():
	var group = read_int()
	match group:
		0: # single
			var skin = mdl_skin.new()
			skin.group = 0
			skin.data = read_byte_buffer(mdl.skin_width * mdl.skin_height)
			return skin
		1: # group
			var skin = mdl_groupskin.new()
			skin.group = 1
			skin.nb = read_int()
			skin.times = read_float_buffer(skin.nb)
			skin.data = read_byte_buffer(skin.nb * mdl.skin_width * mdl.skin_height)
			return skin
	return null

#----------

func read_skins():
	var skins = Array()
	for i in range(mdl.num_skins):
		var skin = read_skin()
		skins.append(skin)
	return skins

#----------

func read_simple_frame():
	var simpleframe = mdl_simpleframe.new()
	simpleframe.type = 0
	simpleframe.bboxmin = read_vertex()
	simpleframe.bboxmax = read_vertex()
	simpleframe.name = read_string()
	simpleframe.verts = read_vertices()
	return simpleframe

#----------

func read_frame_group(frames):
	#var frames = Array()
	var num = read_int();
	#fg.type = num
	#fg.min_ = _read_vertex()
	#fg.max_ = _read_vertex()
	#var time_ = _read_float_buffer(num)
	var min_ = read_vertex()
	var max_ = read_vertex()
	var time_ = read_float_buffer(num)
	for i in range(num):
		var frame = read_simple_frame()
		#fg.frames.append(f)
		frames.append(frame)
	#return frames

#----------

func read_frames():
	var frames = Array()
	var num = mdl.num_frames
	for i in range(num):
		var type = read_int()
		if type == 0:
			var frame = read_simple_frame()
			frames.append(frame)
		else:
			read_frame_group(frames)
	return frames


