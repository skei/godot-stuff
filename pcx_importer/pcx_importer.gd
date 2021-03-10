tool
extends EditorImportPlugin

#----------------------------------------------------------------------

enum Presets { DEFAULT }

#----------

var file = null

#----------------------------------------------------------------------

func get_importer_name():
	return "pcx_importer"

#----------

func get_visible_name():
	return "pcx"

#----------

func get_recognized_extensions():
	return ["pcx"]

#----------

func get_save_extension():
	return "tres"

#----------

func get_resource_type():
	return "ImageTexture"
	#return "Image"

#----------

func get_preset_count():
	return Presets.size()

#----------

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
					"name" : "import_as",
					"default_value" : "scene",
					"property_hint" : PROPERTY_HINT_ENUM,
					"hint_string" : "scene,mesh"
					#"usage" : "" # optional
				},
				{
					"name" : "frame",
					"default_value" : 0
					#"property_hint" : PROPERTY_HINT_NONE # optional
					#"hint_string" : "2" # optional
					#"usage" : "" # optional
				},
				{
					"name" : "skin",
					"default_value" : 0
					#"property_hint" : PROPERTY_HINT_NONE # optional
					#"hint_string" : "2" # optional
					#"usage" : "" # optional
				},
				{
					"name" : "palette",
					"default_value" : "quake",
					"property_hint" : PROPERTY_HINT_ENUM,
					"hint_string" : "quake,hexen"
					#"usage" : "" # optional
				}
#				{
#					"name" : "export_files",
#					"default_value" : false
#					#"property_hint" : PROPERTY_HINT_NONE # optional
#					#"hint_string" : "2" # optional
#					#"usage" : "" # optional
#				}
			]
		_:
			return []

#----------

func get_option_visibility(option, options):
	return true

#----------

func import(source_file, save_path, options, r_platform_variants, r_gen_files):
	var image = read(source_file)
	return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], image)

#----------------------------------------------------------------------
#
#
#
#----------------------------------------------------------------------

#class pcx_header:
#	var id				# The fixed header field valued at a hexadecimal 0x0A (= 10 in decimal).
#	var ver				# The version number referring to the Paintbrush software release, which might be:
#						#	0 PC Paintbrush version 2.5 using a fixed EGA palette
#						#	2 PC Paintbrush version 2.8 using a modifiable EGA palette
#						#	3 PC Paintbrush version 2.8 using no palette
#						#	4 PC Paintbrush for Windows
#						#	5 PC Paintbrush version 3.0, including 24-bit images
#	var enc				# The method used for encoding the image data. Can be:
#						#	0 No encoding (rarely used)
#						#	1 Run-length encoding (RLE)
#	var bits_per_pixel	# The number of bits constituting one pixel in a plane. Possible values are:
#						#	1 The image has two colors (monochrome)
#						#	2 The image has four colors
#						#	4 The image has 16 colors
#						#	8 The image has 256 colors
#	var min_x			# The minimum x co-ordinate of the image position.
#	var min_y			# The minimum y co-ordinate of the image position.
#	var max_x			# The maximum x co-ordinate of the image position.
#	var max_y			# The maximum x co-ordinate of the image position.
#	var hor_dpi			# The horizontal image resolution in DPI.
#	var vert_dpi		# The vertical image resolution in DPI.
#	var ega_palette		# 48 bytes	# The EGA palette for 16-color images.
#	var reserved1		# The first reserved field, usually set to zero.
#	var color_planes	# The number of color planes constituting the pixel data. Mostly chosen to be 1, 3, or 4.
#	var bytes_per_line	# The number of bytes of one color plane representing a single scan line.
#	var palette_mode	# The mode in which to construe the palette:
#						#	1 The palette contains monochrome or color information
#						#	2 The palette contains grayscale information
#	var src_width		# The horizontal resolution of the source system's screen.
#	var src_height		# The vertical resolution of the source system's screen.
#	var reserved2		# The second reserved field, intended for future extensions, and usually set to zero bytes.	

#----------------------------------------------------------------------
#
#
#
#----------------------------------------------------------------------

func read(filename):
	print("reading " + filename)
	
	# open file
	
	var file = File.new()
	#if not file.file_exists(filename):
	#	print("ERROR: file '" + filename + "' does not exist")
	#	return ERR_FILE_NOT_FOUND
	file.open(filename,File.READ)
	
	# read header
	
	#var header = pcx_header.new()
	var header_id				= file.get_8()
	var header_ver				= file.get_8()
	var header_enc				= file.get_8()
	var header_bits_per_pixel	= file.get_8()
	var header_min_x			= file.get_16()
	var header_min_y			= file.get_16()
	var header_max_x			= file.get_16()
	var header_max_y			= file.get_16()
	var header_hor_dpi			= file.get_16()
	var header_vert_dpi			= file.get_16()
	var header_ega_palette		= file.get_buffer(48)
	var header_reserved1		= file.get_8()
	var header_color_planes		= file.get_8()
	var header_bytes_per_line	= file.get_16()
	var header_palette_mode		= file.get_16()
	var header_src_width		= file.get_16()
	var header_src_height		= file.get_16()
	var header_reserved2		= file.get_buffer(54)
	
	# print header
	
	print("  id " + str(header_id))
	print("  ver " + str(header_ver))
	print("  enc " + str(header_enc))
	print("  bits_per_pixel " + str(header_bits_per_pixel))
	print("  min_x " + str(header_min_x))
	print("  min_y " + str(header_min_y))
	print("  max_x " + str(header_max_x))
	print("  max_y " + str(header_max_y))
	print("  hor_dpi " + str(header_hor_dpi))
	print("  vert_dpi " + str(header_vert_dpi))
	print("  color_planes " + str(header_color_planes))
	print("  bytes_per_line " + str(header_bytes_per_line))
	print("  palette_mode " + str(header_palette_mode))
	print("  src_width " + str(header_src_width))
	print("  src_height " + str(header_src_height))
	
	# read image
	
	var numread = 0
	var byte = 0
	var runlen = 0
	var buffer = PoolByteArray()
	var width = header_max_x - header_min_x + 1
	var height = header_max_y - header_min_y + 1
	var imagelength = header_bytes_per_line * height
	while numread < imagelength and not file.eof_reached():
		byte = file.get_8()
		# see if first 2 bits are 1s
		if byte & 0xc0 == 0xc0:
			runlen = byte & 0x3f
			byte = file.get_8()
			for j in range(runlen):
				buffer.append(byte)
				numread += 1
		else:
			buffer.append(byte)
			numread += 1
	
	# read palette
	
	var palette
	file.seek_end(-769)
	var has_palette = file.get_8()
	if has_palette == 12:
		palette = file.get_buffer(768)
	
	#palette.set(254, Color(0x00000080))
	#palette.set(255, Color(0x00000000))
	#palette.set(253, Color(0xffffffff))
	
	# create image
	
	var image = Image.new()
	image.create(width,height,false,Image.FORMAT_RGBAF)
	image.lock()
	for y in range(height):
		for x in range(width):
			#var c = imagebuffer[(y * width) + x]
			var c = buffer[(y * header_bytes_per_line) + x]
			var r = palette[(c*3)  ] / 255.0
			var g = palette[(c*3)+1] / 255.0
			var b = palette[(c*3)+2] / 255.0
			var color = Color(r,g,b)
			image.set_pixel(x,y,color)
	image.unlock()
	
	# create texture
	
	var texture = ImageTexture.new()
	texture.create_from_image(image,0)
	texture.flags = 0
	
	# clean up
	
	file.close()
	#file = null
	
	#return image
	return texture

#----------

	#var palette = PoolColorArray()
	#palette.resize(256)
	#for i in range(256):
	#	palette[i] = Color(
	#		palettebytes[i * 3] * 256 * 256 * 256 +
	#		palettebytes[i * 3 + 1] * 256 * 256 +
	#		palettebytes[i * 3 + 2] * 256 +
	#		255
	#	)

	# set shadow and transprent color values
	# This isn't quite right
	#for i in range(16):
	#	# Shadow colors
	#	palette.set(255 - i, Color(0.0, 0.0, 0.0, i / 15.0))
	#	# Smoke/fog colors
	#	palette.set(224 + i, Color(1.0, 1.0, 1.0, i / 15.0))
	#palette.set(254, Color(0x00000080))
	#palette.set(255, Color(0x00000000))
	#palette.set(253, Color(0xffffffff))

	# Attempt at changing hue on civ colors to preserve intensity
	#var color
	#for i in range(64):
	#	color = palette[i]
	#	if i < 16 or i % 2 == 0:
	#		# Alhpa-keying civ colors so civ color shader can hue-shift them
	#		color.a = 0.1
	#		palette[i] = color
