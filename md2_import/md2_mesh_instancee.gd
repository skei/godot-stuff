tool
extends MeshInstance
class_name MD2MeshInstancee

#----------------------------------------------------------------------

var md2 = null
var _filename = ""

export(String, FILE, "*.md2") var md2_file = "" setget set_filename, get_filename
#export(int) var md2_frame = 0 setget set_frame, get_frame
#export(int) var md2_skin = 0 setget set_skin, get_skin

#var _frame = 0
#var _skin = 0

#----------------------------------------------------------------------

func _init():
	md2 = load("res://addons/md2_import/md2_base.gd").new()

func set_filename(fn):
	_filename = fn
	if _filename == "":
		return
	else:
		var result = md2.importer.read_file(fn)
		if result != OK:
			return
		md2.converter.update_mesh_instance(self,0,0)

func get_filename():
	return _filename

#func set_frame(f):
#	_frame = f
#	var m = import_mesh(_filename,f)
#	update_mesh(m)

#func get_frame():
#	return _frame

#func set_skin(s):
#	_skin = s
#	update_material(s)

#func get_skin():
#	return _skin

#----------------------------------------------------------------------

#func import_mesh(_fname,_frm):
##	if md2 == null:
##		return null
##	var result = md2.importer.read_file(_fname)
##	if result != OK:
##		return null
##	var mesh_ = md2.converter.create_mesh(_frm)
##	mesh_.set_custom_aabb(AABB(Vector3(0,0,0), Vector3(1,1,1)))
##	return mesh_
#	return null
#
#func update_mesh(mesh_):
##	if mesh_:
##		mesh = mesh_
##		var mat_ = md2.converter.create_material(0)
##		set_surface_material(0,mat_)
##		rotation.x = -PI / 2.0
##		#mesh.extra_cull_margin = 1.0
##	else:
##		mesh = null #.free()
#	pass
#
#func update_material(skin_):
##	var mat_ = md2.converter.create_material(skin_)
##	set_surface_material(0,mat_)
#	pass
#
#func clear_mesh():
#	mesh = null
#
#func clear_material():
#	set_surface_material(0,null)
