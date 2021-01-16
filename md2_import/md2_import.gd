#tool
extends Reference

#----------------------------------------------------------------------

const INV_255 = (1.0 / 255.0)
var md2 = null;
var _file = null

#----------------------------------------------------------------------

func _init(base):
	md2 = base
	_file = File.new()

#----------------------------------------------------------------------

func read_file(filename):
	#print("md2_import.read_file('" + filename + "')")
	md2.reset()
#	#_filename = filename
	if not _file.file_exists(filename):
		print("ERROR: file '" + filename + "' does not exist")
		return ERR_FILE_NOT_FOUND
	_file.open(filename,File.READ)
	_read_header()
	#md2.print_header()
	_read_skins()
	_read_texcoords()
	_read_triangles()
	_read_glcmds()
	_read_frames()
	_file.close()
	return OK

#----------------------------------------------------------------------
# read generic
#----------------------------------------------------------------------

func _read_byte():
	return _file.get_8()

#----------

func _read_short():
	return _file.get_16()

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

# length = 16
func _read_string(length):
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

func _read_byte_buffer(size):
	var b = _file.get_buffer(size)
	return b

#----------

func _read_float_buffer(size):
	var data = _file.get_buffer(size * 4)
	return data

#----------------------------------------------------------------------
# read md2 specific
#----------------------------------------------------------------------

func _read_header():
	#print("md2_import._read_header")
	md2.header = md2.MD2Header.new()
	md2.header.ident = _read_int()
	if md2.header.ident != 844121161 :
		print("ERROR: wrong header.ident " + str(md2.header.ident) + " (should be 844121161 )")
		return ERR_FILE_CORRUPT
	md2.header.version = _read_int()
	if md2.header.version != 8:
		print("ERROR: wrong header.version " + str(md2.header.version) + " (should be 8)")
		return ERR_FILE_UNRECOGNIZED
	md2.header.skin_width = _read_int()
	md2.header.skin_height = _read_int()
	md2.header.frame_size = _read_int()
	md2.header.num_skins = _read_int()
	md2.header.num_vertices = _read_int()
	md2.header.num_st = _read_int()
	md2.header.num_tris = _read_int()
	md2.header.num_glcmds = _read_int()
	md2.header.num_frames = _read_int()
	md2.header.offset_skins = _read_int()
	md2.header.offset_st = _read_int()
	md2.header.offset_tris = _read_int()
	md2.header.offset_frames = _read_int()
	md2.header.offset_glcmds = _read_int()
	md2.header.offset_end = _read_int()
	return OK

#----------

# swap x/y

func _read_vertex():
	var v = md2.MD2Vertex.new()
	var vec = _read_vector8()
	vec *= INV_255
	vec -= Vector3(0.5,0.5,0.5)
	v.pos = vec
	v.normal = _read_byte()
	return v

func _read_vertices():
	var vert = Array()
	for _i in range(md2.header.num_vertices):
		var v = _read_vertex()
		vert.append( v )
	return vert

#----------

func _read_texcoord():
	var tc = md2.MD2TexCoord.new()
#	tc.on_seam = _file.get_32()
	var u = _file.get_16()
	var v = _file.get_16()
	var uv = Vector2(u,v)
	#u = (u + 0.5) / md2.header.skin_width
	#v = (v + 0.5) / md2.header.skin_height
	uv.x /=  md2.header.skin_width
	uv.y /=  md2.header.skin_height
	tc.uv = uv
	return tc

func _read_texcoords():
	_file.seek(md2.header.offset_st)
	for _i in range(md2.header.num_st):
		var tc = _read_texcoord()
		md2.texcoords.append(tc)

#----------

func _read_triangle():
	var t = md2.MD2Triangle.new()
#	t.front_facing = _file.get_32() == 1
	t.v1 = _file.get_16()
	t.v2 = _file.get_16()
	t.v3 = _file.get_16()
	t.uv1 = _file.get_16()
	t.uv2 = _file.get_16()
	t.uv3 = _file.get_16()
	return t

func _read_triangles():
	_file.seek(md2.header.offset_tris)
	for _i in range(md2.header.num_tris):
		var t = _read_triangle()
		md2.triangles.append(t)

#----------

func _read_glcmds():
	_file.seek(md2.header.offset_glcmds)
	pass

#----------

func _read_skin():
	var s = md2.MD2Skin.new()
	s.name = _read_string(64)
	return s

#----------

func _read_skins():
	_file.seek(md2.header.offset_skins)
	for _i in range(md2.header.num_skins):
		var s = _read_skin()
		md2.skins.append(s)

#----------

func _read_frame():
	var f = md2.MD2Frame.new()
	f.scale = _read_vector()
	f.translate = _read_vector()
	f.name = _read_string(16)
	f.verts = _read_vertices()
	return f

func _read_frames():
	_file.seek(md2.header.offset_frames)
	var num = md2.header.num_frames
	for i in range(num):
		var f = _read_frame()
		md2.frames.append(f)
