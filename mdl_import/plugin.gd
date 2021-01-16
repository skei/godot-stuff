tool
extends EditorPlugin

var _plugin

func _enter_tree():
	#print("enter")
	_plugin = preload("mdl_import_plugin.gd").new()
	add_import_plugin(_plugin)

func _exit_tree():
	#print("exit")
	remove_import_plugin(_plugin)
	_plugin = null
