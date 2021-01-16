#tool
extends Reference

#----------------------------------------------------------------------

const INV_255 = (1.0 / 255.0)
var mdl = null;
var _file = null

#----------------------------------------------------------------------

func _init(base):
	mdl = base

#----------------------------------------------------------------------

func read_file(filename):
	mdl.reset()
#	#_filename = filename
	_file = File.new()
	if not _file.file_exists(filename):
		print("ERROR: file '" + filename + "' does not exist")
		return ERR_FILE_NOT_FOUND
	_file.open(filename,File.READ)
	_read_header()
	#mdl.print_header()
	_read_skins()
	_read_texcoords()
	_read_triangles()
	_read_frames()
	_file.close()
	return OK

#----------------------------------------------------------------------
# read generic
#----------------------------------------------------------------------

func _read_byte():
	return _file.get_8()

#----------

func _read_int():
	return _file.get_32()

#----------

func _read_float():
	return _file.get_float()

#----------

func _read_vector():
	var x = _file.get_float()
	var y = _file.get_float()
	var z = _file.get_float()
	var v = Vector3(x,y,z)
	return v

func _read_vector8():
	var x = _file.get_8()
	var y = _file.get_8()
	var z = _file.get_8()
	var v = Vector3(x,y,z)
	return v

#----------

func _read_string():
	var zero = false
	var s = String()
	for _i in range(16):
		var c = _file.get_8()
		if c == 0:
			zero = true
		if not zero:
			s += String("%c" % c)
	return s

#----------

func _read_byte_buffer(size):
	var b = _file.get_buffer(size)
	return b

#----------

func _read_float_buffer(size):
	var data = _file.get_buffer(size * 4)
	return data

#----------------------------------------------------------------------
# read mdl specific
#----------------------------------------------------------------------

func _read_header():
	mdl.header					= mdl.MDLHeader.new()
	mdl.header.ident			= _read_int()
	if mdl.header.ident != 1330660425:
		print("ERROR: wrong header.ident " + str(mdl.header.ident) + " (should be 1330660425)")
		return ERR_FILE_CORRUPT
	mdl.header.version			= _read_int()
	if mdl.header.version != 6:
		print("ERROR: wrong header.version " + str(mdl.header.version) + " (should be 6)")
		return ERR_FILE_UNRECOGNIZED
	mdl.header.scale			= _read_vector()
	mdl.header.translate		= _read_vector() * INV_255
	mdl.header.bounding_radius	= _read_float() * INV_255
	mdl.header.eye_position		= _read_vector() * INV_255
	mdl.header.num_skins		= _read_int()
	mdl.header.skin_width		= _read_int()
	mdl.header.skin_height		= _read_int()
	mdl.header.num_verts		= _read_int()
	mdl.header.num_tris			= _read_int()
	mdl.header.num_frames		= _read_int()
	mdl.header.sync_type		= _read_int()
	mdl.header.flags			= _read_int()
	mdl.header.size				= _read_float()
	return OK

#----------

# swap x/y

func _read_vertex():
	var v = mdl.MDLVertex.new()
	var vec = _read_vector8()
	#vec *= INV_255
	#vec -=  Vector3(0.5, 0.5, 0.5)
	v.pos = vec
	v.normal = _read_byte() # _file.get_8()
	return v

#----------

func _read_vertices():
	var vert = Array()
	for _i in range(mdl.header.num_verts):
		var v = _read_vertex()
		vert.append( v )
	return vert

#----------

func _read_texcoord():
	var tc = mdl.MDLTexCoord.new()
	tc.on_seam = _file.get_32()
	var u = _file.get_32()
	var v = _file.get_32()
	u = (u + 0.5) / mdl.header.skin_width
	v = (v + 0.5) / mdl.header.skin_height
	tc.uv = Vector2(u,v)
	return tc

#----------

func _read_texcoords():
	for _i in range(mdl.header.num_verts):
		var tc = _read_texcoord()
		mdl.texcoords.append(tc)

#----------

func _read_triangle():
	var t = mdl.MDLTriangle.new()
	t.front_facing = _file.get_32() == 1
	t.v1 = _file.get_32()
	t.v2 = _file.get_32()
	t.v3 = _file.get_32()
	return t

#----------

func _read_triangles():
	for _i in range(mdl.header.num_tris):
		var t = _read_triangle()
		mdl.triangles.append(t)

#----------

func _read_skin():
	var gr = _read_int()
	match gr:
		0: # single
			var s = mdl.MDLSkin.new()
			s.group = 0
			s.data	= _read_byte_buffer(mdl.header.skin_width * mdl.header.skin_height)
			return s
		1: # group
			var s = mdl.MDLSkinGroup.new()
			s.group = 1
			s.nb	= _read_int()
			s.times	= _read_float_buffer(s.nb)
			s.data	= _read_byte_buffer(s.nb * mdl.header.skin_width * mdl.header.skin_height)
			return s
	return null

#----------

func _read_skins():
	for _i in range(mdl.header.num_skins):
		var s = _read_skin()
		mdl.skins.append(s)

#----------

func _read_simple_frame():
	var f = mdl.MDLSimpleFrame.new()
	f.type		= 0
	f.bboxmin	= _read_vertex()
	f.bboxmax	= _read_vertex()
	f.name		= _read_string()
	f.verts		= _read_vertices()
	return f

#----------

func _read_frame_group():
	#var fg = mdl.MDLFrameGroup.new()
	var num_ = _read_int();
	#fg.type = num
	#fg.min_ = _read_vertex()
	#fg.max_ = _read_vertex()
	#var time_ = _read_float_buffer(num)
	var min_ = _read_vertex()
	var max_ = _read_vertex()
	var time_ = _read_float_buffer(num_)
	for _i in range(num_):
		var f = _read_simple_frame()
		#fg.frames.append(f)
		mdl.frames.append(f)
	#return fg

#----------

func _read_frames():
	var num = mdl.header.num_frames
	for _i in range(num):
		var type = _read_int()
		if type == 0:
			var f = _read_simple_frame()
			mdl.frames.append(f)
		else:
			_read_frame_group()
