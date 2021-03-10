tool
extends EditorPlugin


var _plugin = null


func _enter_tree():
	#print("_enter_tree")
	_plugin = preload("md2_importer.gd").new()
	add_import_plugin(_plugin)


func _exit_tree():
	remove_import_plugin(_plugin)
	_plugin = null
