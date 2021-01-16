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

class MD2Header:
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

class MD2Skin:
	var name = String()				# texture file name

class MD2TexCoord:
	var uv = Vector2()				# short

class MD2Triangle:
	var v1							# vertex indices
	var v2							#
	var v3							#
	var uv1							# vertex indices
	var uv2							#
	var uv3							#

class MD2Vertex:
	var pos = Vector3()				#
	var normal						#

class MD2Frame:
	var scale = Vector3()			# scale factor
	var translate = Vector3()		# translation vector
	var name = String()				# frame name
	var verts = Array()				# list of frame's vertices

#----------------------------------------------------------------------

func print_header():
	#print(filename)
	print("  ident          : " + str(header.ident))
	print("  version        : " + str(header.version))
	print("  skin_width     : " + str(header.skin_width))
	print("  skin_height    : " + str(header.skin_height))
	print("  frame_size     : " + str(header.frame_size))
	print("  num_skins      : " + str(header.num_skins))
	print("  num_vertices   : " + str(header.num_vertices))
	print("  num_st         : " + str(header.num_st))
	print("  num_tris       : " + str(header.num_tris))
	print("  num_glcmds     : " + str(header.num_glcmds))
	print("  num_frames     : " + str(header.num_frames))
	print("  offset_skins   : " + str(header.offset_skins))
	print("  offset_st      : " + str(header.offset_st))
	print("  offset_tris    : " + str(header.offset_tris))
	print("  offset_frames  : " + str(header.offset_frames))
	print("  offset_glcmds  : " + str(header.offset_glcmds))
	print("  offset_end     : " + str(header.offset_end))

#----------

func print_skins():
#	for i in range(header.num_skins):
#		print("skin " + str(i) + " group " + str(skins[i].group))
	pass

#----------

func print_vertex(f,v):
#	var vertex = frames[f].verts[v]
#	print("    vertex %d pos %f,%f,%f normal %d" % [v,vertex.pos.x,vertex.pos.y,vertex.pos.z,vertex.normal])
	pass

#----------

func print_vertices(f):
#	for v in range(header.num_verts):
#		print_vertex(f,v)
	pass

#----------

func print_frame(f):
#	match(frames[f].type):
#		0:
#			print("  type " + str(frames[f].type))
#			print("  bboxmin " + str(frames[f].bboxmin))
#			print("  bboxmax " + str(frames[f].bboxmax))
#			print("  name " + frames[f].name)
#			#print_vertices(f)
#		_:
#			print("  type " + str(frames[f].type))
#			print("  min " + str(frames[f].min_))
#			print("  max " + str(frames[f].max_))
#			#print_vertices(f)
	pass

#----------

func print_frames():
#	for i in range(header.num_frames):
#		print("frame " + str(i))
	pass

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
	importer = load("res://addons/md2_import/md2_import.gd").new(self)
	converter = load("res://addons/md2_import/md2_convert.gd").new(self)

#----------

func reset():
	header = null
	skins.clear()
	texcoords.clear()
	triangles.clear()
	frames.clear()
	file = null
	is_loaded = false
