tool
extends EditorImportPlugin

# https://docs.godotengine.org/en/stable/tutorials/plugins/editor/import_plugins.html

#----------------------------------------------------------------------

enum Presets { DEFAULT }

var mdl = preload("res://addons/mdl_import/mdl_base.gd").new()
#var mdl = preload("mdl_base.gd").new()

#----------------------------------------------------------------------

#func _init():
#	print("_init")

#----------

func get_importer_name():
	return "skei_mdl_importer"

#----------

func get_visible_name():
	return "MDL"

#----------

func get_recognized_extensions():
	return ["mdl"]

#----------

func get_save_extension():
	return "tscn"

#----------

func get_resource_type():
	return "PackedScene"

#----------

func get_preset_count():
	return Presets.size()

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
					"name"  : "frame",
					"default_value" : 0
					#"property_hint" : PROPERTY_HINT_NONE # optional
					#"hint_string" : "2" # optional
					#"usage" : "" # optional
				},
				{
					"name"  : "skin",
					"default_value" : 0
					#"property_hint" : PROPERTY_HINT_NONE # optional
					#"hint_string" : "2" # optional
					#"usage" : "" # optional
				},
				{
					"name"  : "export_files",
					"default_value" : false
					#"property_hint" : PROPERTY_HINT_NONE # optional
					#"hint_string" : "2" # optional
					#"usage" : "" # optional
				}
			]
		_:
			return []

#----------

func get_option_visibility(option, options):
	return true

#----------------------------------------------------------------------

func _init():
	#print("mdl_import_plugin._init")
	pass

#----------------------------------------------------------------------

func import(source_file, save_path, options, r_platform_variants, r_gen_files):

	var result = mdl.importer.read_file(source_file)
	#mdl.print_header()
	
	if result != OK:
		return ERR_FILE_CANT_READ
	
	if options.export_files:
		
		var filename = source_file.get_basename()
		
		print("creating mesh")
		
		var mesh = mdl.converter.create_mesh(options.frame)
		ResourceSaver.save("%s.%s" % [filename, "mesh"], mesh)
		
		print("creating vertex texture")
		
		var vat_vertices = mdl.converter.create_image_from_anim()
		var texture = mdl.converter.create_texture_from_image(vat_vertices)
		ResourceSaver.save("%s_vertices.%s" % [filename, "tex"], texture) # vat_vertices)
		
		print("creating normal texture")
		
		var vat_normals = mdl.converter.create_image_from_normals()
		texture = mdl.converter.create_texture_from_image(vat_normals)
		ResourceSaver.save("%s_normals.%s" % [filename, "tex"], texture) # vat_normals)
		
		print("creating skins")

		for i in range(mdl.header.num_skins):
			var skin = mdl.converter.create_image_from_skin(i)
			texture = mdl.converter.create_texture_from_image(skin)
			ResourceSaver.save("%s_skin%s.%s" % [filename, str(i), "tex"], texture) # skin)
		
		print("creating shader")
		
		var shader = mdl.converter.create_shader()
		ResourceSaver.save("%s.%s" % [filename, "shader"], shader)
		
		##create_texture_from_image(img)
		#func create_material(skin)
	
	#----------
	
	var name = "mdl"
	var scene = mdl.converter.create_scene(name,options.frame,options.skin)
	return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], scene)
