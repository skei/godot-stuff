#tool
extends Reference

#----------------------------------------------------------------------

const INV_255 = (1.0 / 255.0)

var md2 = null;

#----------------------------------------------------------------------

func _init(base):
	md2 = base

#----------------------------------------------------------------------
#
#----------------------------------------------------------------------

# v1,v2,v3 or v1,v3,v2 ??

func calc_vertex_normals(fr):
	var vertices = md2.frames[fr].verts
	#var tri_normals = calc_tri_normals(frame)
	var vert_normals = []
	vert_normals.resize(md2.header.num_vertices)
	for v in range(md2.header.num_vertices):
		vert_normals[v] = Vector3()
	for t in range(md2.header.num_tris):
		var tri = md2.triangles[t]
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
	for v in range(md2.header.num_vertices):
		vert_normals[v] = vert_normals[v].normalized()
	return vert_normals

#----------

func get_description():
	var d = ""
	d += "skin_width: " + str(md2.header.skin_width) + "\n"
	d += "skin_height: " + str(md2.header.skin_height) + "\n"
	d += "frame_size: " + str(md2.header.frame_size) + "\n"
	d += "num_skins : " + str(md2.header.num_skins) + "\n"
	d += "num_vertices: " + str(md2.header.num_vertices) + "\n"
	d += "num_tris: " + str(md2.header.num_tris) + "\n"
	d += "num_glcmds: " + str(md2.header.num_glcmds) + "\n"
	d += "num_frames: " + str(md2.header.num_frames) + "\n"
	d += "skins...\n"
	for s in range(md2.header.num_skins):
		d += str(s) + ". "
		d += md2.skins[s].name
		d += " "
	d += "\n"
	d += "frames...\n"
	for f in range(md2.header.num_frames):
		d += str(f) + ":"
		d += md2.frames[f].name
		d += " "
	d += "\n"
	return d

#----------------------------------------------------------------------
#
#----------------------------------------------------------------------

func create_image_from_skin(skin):
	var img = Image.new()
	var w = md2.header.skin_width
	var h = md2.header.skin_height
	var sd = md2.skins[skin].data
	img.create(w,h,false,Image.FORMAT_RGBA8)
	img.lock()
	for y in range(h):
		for x in range(w):
			var i = y * w + x
			var c = sd[i]
			var col = Color( md2.MD2Palette[c] )
			img.set_pixel(x,y,col)
	img.unlock()
	return img

#----------

func create_image_from_all_skins():
	var img = Image.new()
	var w = md2.header.skin_width
	var h = md2.header.skin_height
	var sh = h * md2.header.num_skins
	img.create(w,sh,false,Image.FORMAT_RGBA8)
	img.lock()
	for s in range(md2.header.num_skins):
		var sd = md2.skins[s].data
		for y in range(h):
			for x in range(w):
				var i = y * w + x
				var c = sd[i]
				var col = Color( md2.MD2Palette[c] )
				img.set_pixel(x,(s*h)+y,col)
	img.unlock()
	return img

#----------

func create_image_from_vertices():
	var img = Image.new()
	var w = md2.header.num_vertices
	var h = md2.header.num_frames
	img.create(w,h,false,Image.FORMAT_RGBAF)
	img.lock()
	for y in range(h):
		var frame = md2.frames[y]
		for x in range(w):
			var vtx = frame.verts[x].pos
			#vtx *= INV_255
			var col = Color( vtx.x, vtx.y, vtx.z, 1.0 )
			img.set_pixel(x,y,col)
	img.unlock()
	return img

#----------

func create_image_from_normals():
	var img = Image.new()
	var w = md2.header.num_vertices
	var h = md2.header.num_frames
	img.create(w,h,false,Image.FORMAT_RGBAF)
	img.lock()
	for y in range(h):
		var normals = calc_vertex_normals(y)
		var frame = md2.frames[y]
		for x in range(w):
			var nor = normals[x]
			var col = Color( nor.x, nor.y, nor.z, 1.0 )
			img.set_pixel(x,y,col)
	img.unlock()
	return img

#----------

func create_texture_from_image(img):
	var tex = ImageTexture.new()
	tex.create_from_image(img,0)
	return tex

#----------

func create_texture_from_skin(skin):
	var img = create_image_from_skin(skin)
	var tex = ImageTexture.new()
	tex.create_from_image(img,0)
	return tex

#----------

func create_texture_from_all_skins():
	var img = create_image_from_all_skins()
	var tex = ImageTexture.new()
	tex.create_from_image(img,0)
	return tex

#----------

func create_shader():
	#var sha = Shader.new()
	#sha.code = md2.MD2Shader
	var sha = load("res://addons/md2_import/md2_shader.shader")
	return sha

#----------

func create_material(skin):
	#var simg = create_image_from_skin(skin)
#	var simg = create_image_from_all_skins()
	var aimg = create_image_from_vertices()
	var nimg = create_image_from_normals()
#	var stex = create_texture_from_image(simg)
	var atex = create_texture_from_image(aimg)
	var ntex = create_texture_from_image(nimg)
	
	var mat = ShaderMaterial.new()
	var sha = create_shader()
	mat.shader = sha

#	mat.set_shader_param("scale",md2.header.scale)
#	mat.set_shader_param("translate",(md2.header.translate))
	#mat.set_shader_param("size",md2.header.size)
	mat.set_shader_param("start_frame",0)
	mat.set_shader_param("end_frame",md2.header.num_frames - 1)
	mat.set_shader_param("interpolate",true)
	mat.set_shader_param("wraparound",true)
	if md2.header.num_frames > 0:
		mat.set_shader_param("automate",true)
	else:
		mat.set_shader_param("automate",false)
	mat.set_shader_param("fps",10.0)
	mat.set_shader_param("anim_offset",0.0)
	#mat.set_shader_param("num_skins",md2.header.num_skins)
	mat.set_shader_param("num_skins",1)
	mat.set_shader_param("skin_index",0)
#	mat.set_shader_param("skin_texture",stex)
	mat.set_shader_param("vertex_texture",atex)
	mat.set_shader_param("normal_texture",ntex)
	
	return mat

#----------

func _get_vertex(frame,index):
	var frm = md2.frames[frame]
	var vtx = frm.verts[index].pos
	#var vec = vtx * INV_255
	#return vec
	return vtx

func _get_normal(normals,index):
	var norm = normals[index]
	return norm

func _get_uv(index):
	var tc = md2.texcoords[index].uv
	var uv = tc # Vector2(tc.x,tc.y)
	return uv

func _get_color(index):
	var r = (index & 0xff) / 255.0
	var g = ((index & 0xff00) >> 8) / 255.0
	var b = (((index & 0xff0000) >> 16)) / 255.0
	var col = Color(r,g,b,1)
	return col

#----------

#func create_mesh(frame,skin):
func create_mesh(frame):
	#var frm = md2.frames[frame]
	var normals = calc_vertex_normals(frame)
	var vert_ = PoolVector3Array()
	var texc_ = PoolVector2Array()
	var col_ = PoolColorArray()
	var norm_ = PoolVector3Array()
	var num_tris = md2.header.num_tris
	for i in range(num_tris):
		
		var tri = md2.triangles[i]
		var v1 = tri.v1
		var v2 = tri.v2
		var v3 = tri.v3
		var uv1 = tri.uv1
		var uv2 = tri.uv2
		var uv3 = tri.uv3
		
		# v1
		
		vert_.push_back(_get_vertex(frame,v1))
		norm_.push_back(_get_normal(normals,v1))
		texc_.push_back(_get_uv(uv1))
		col_.push_back(_get_color(v1))
		
		vert_.push_back(_get_vertex(frame,v2))
		norm_.push_back(_get_normal(normals,v2))
		texc_.push_back(_get_uv(uv2))
		col_.push_back(_get_color(v2))
		
		vert_.push_back(_get_vertex(frame,v3))
		norm_.push_back(_get_normal(normals,v3))
		texc_.push_back(_get_uv(uv3))
		col_.push_back(_get_color(v3))
		
	var mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vert_
	arrays[ArrayMesh.ARRAY_TEX_UV] = texc_
	arrays[ArrayMesh.ARRAY_COLOR] = col_
	arrays[ArrayMesh.ARRAY_NORMAL] = norm_
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	#var aabb = AABB( Vector3(-0.5,-0.5,-0.5), Vector3(1,1,1) )
	#mesh.set_custom_aabb(aabb)
	
	return mesh

#----------

func create_mesh_instance(frame,skin):
	var mesh = create_mesh(frame)
	var mat = create_material(skin)
	mesh.surface_set_material(0,mat)
	mesh.surface_set_name(0,"md2 shader")
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = mesh
	#mesh_instance.rotation.x = -PI / 2.0	
	#mesh_instance.extra_cull_margin = 1.0
	var numframes = md2.header.num_frames
	var d = get_description()
	mesh_instance.editor_description = d
	return mesh_instance

#----------

func update_mesh_instance(mesh_instance,frame,skin):
	var mesh = create_mesh(frame)
	var mat = create_material(skin)
	mesh.surface_set_material(0,mat)
	mesh.surface_set_name(0,"md2 shader")
	mesh_instance.mesh = mesh
	#mesh_instance.rotation.x = -PI / 2.0	
	#mesh_instance.extra_cull_margin = 1.0
	var numframes = md2.header.num_frames
	var d = get_description()
	mesh_instance.editor_description = d

#----------

func create_scene(name,frame,skin):
	var mesh_instance = create_mesh_instance(frame,skin)
	var scene = PackedScene.new()
	scene.pack(mesh_instance)
	return scene
