tool
extends EditorImportPlugin

# https://docs.godotengine.org/en/stable/tutorials/plugins/editor/import_plugins.html

#----------------------------------------------------------------------

enum Presets { DEFAULT }

var md2 = preload("res://addons/md2_import/md2_base.gd").new()
#var mdl = preload("md2_base.gd").new()

#----------------------------------------------------------------------

#func _init():
#	print("_init")

#----------

func get_importer_name():
	return "skei_md2_importer"

#----------

func get_visible_name():
	return "MD2"

#----------

func get_recognized_extensions():
	return ["md2"]

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

	var result = md2.importer.read_file(source_file)
	#md2.print_header()
	
	if result != OK:
		return ERR_FILE_CANT_READ
	
	if options.export_files:
		
		var filename = source_file.get_basename()
		
		print("creating mesh")
		
		var mesh = md2.converter.create_mesh(options.frame)
		ResourceSaver.save("%s.%s" % [filename, "mesh"], mesh)
		
		print("creating vertex texture")
		
		var vat_vertices = md2.converter.create_image_from_anim()
		var texture = md2.converter.create_texture_from_image(vat_vertices)
		ResourceSaver.save("%s_vertices.%s" % [filename, "tex"], texture) # vat_vertices)
		
		print("creating normal texture")
		
		var vat_normals = md2.converter.create_image_from_normals()
		texture = md2.converter.create_texture_from_image(vat_normals)
		ResourceSaver.save("%s_normals.%s" % [filename, "tex"], texture) # vat_normals)
		
		print("creating skins")

		#for i in range(md2.header.num_skins):
		#	var skin = md2.converter.create_image_from_skin(i)
		#	texture = md2.converter.create_texture_from_image(skin)
		#	ResourceSaver.save("%s_skin%s.%s" % [filename, str(i), "tex"], texture) # skin)
		
		#print("creating shader")
		#
		#var shader = md2.converter.create_shader()
		#ResourceSaver.save("%s.%s" % [filename, "shader"], shader)
		
		##create_texture_from_image(img)
		#func create_material(skin)
	
	#----------
	
	var name = "md2"
	var scene = md2.converter.create_scene(name,options.frame,options.skin)
	return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], scene)

