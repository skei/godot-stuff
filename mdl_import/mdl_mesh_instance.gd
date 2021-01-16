tool
extends MeshInstance
class_name MDLMeshInstance

#----------------------------------------------------------------------

var mdl = null
#onready var mdl = preload("res://addons/mdl_import/mdl_base.gd").new()

export(String, FILE, "*.mdl") var mdl_file = "" setget set_filename, get_filename
export(int) var mdl_frame = 0 setget set_frame, get_frame
export(int) var mdl_skin = 0 setget set_skin, get_skin

var _filename = ""
var _frame = 0
var _skin = 0

#----------------------------------------------------------------------

func _init():
	mdl = load("res://addons/mdl_import/mdl_base.gd").new()
	#if _mdl == null:
	#	print("null")
	#else:
	#	_mdl.new()

#func _ready():
#	if _filename != "":
#		var m = import_mesh(_filename,_frame)
#		update_mesh(m)
#		update_material(_skin)

func set_filename(fn):
	_filename = fn
	if _filename == "":
		clear_mesh()
		#mdl.is_loaded = false
	else:
		var m = import_mesh(fn,_frame)
		print("mdl: " + _filename)
		print( str(mdl.header.num_frames) + " frames")
		print( str(mdl.header.num_skins) + " skins")
		if m != null:
			update_mesh(m)
			#mdl.is_loaded = true

func get_filename():
	return _filename

func set_frame(f):
	print("set frame: " + str(f))
	#if mdl.is_loaded:
	_frame = f
	var m = import_mesh(_filename,f)
	update_mesh(m)
	#else:
	#	print("mdl not loaded")
	#	_frame = 0
	#	clear_mesh()

func get_frame():
	return _frame

func set_skin(s):
	print("set skin: " + str(s))
	_skin = s
	update_material(s)

func get_skin():
	return _skin

#----------------------------------------------------------------------

func import_mesh(_fname,_frm):
	if mdl == null:
		return null
	var result = mdl.importer.read_file(_fname)
	if result != OK:
		return null
	var mesh_ = mdl.converter.create_mesh(_frm)
	mesh_.set_custom_aabb(AABB(Vector3(0,0,0), Vector3(1,1,1)))
	return mesh_

func update_mesh(mesh_):
	if mesh_:
		mesh = mesh_
		var mat_ = mdl.converter.create_material(0)
		set_surface_material(0,mat_)
		rotation.x = -PI / 2.0
		#mesh.extra_cull_margin = 1.0
	else:
		mesh = null #.free()

func update_material(skin_):
	var mat_ = mdl.converter.create_material(skin_)
	set_surface_material(0,mat_)

func clear_mesh():
	mesh = null

func clear_material():
	set_surface_material(0,null)

