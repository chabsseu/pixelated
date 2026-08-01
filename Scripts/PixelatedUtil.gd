extends Node
class_name PixelateUtil


static func load_image_from_path(path: String) -> Image:
	var img: Image = Image.new()
	var err: int = img.load(path)

	if err != OK:
		push_error("Failed to load image at %s (error %d)" % [path, err])
		return null

	img.convert(Image.FORMAT_RGB8)
	return img

static func load_image_from_bytes(bytes: PackedByteArray) -> Image:
	# For Android/web builds — no real file path, just raw image bytes.
	var img := Image.new()
	var err := img.load_jpg_from_buffer(bytes)
	if err != OK:
		err = img.load_png_from_buffer(bytes)
	if err != OK:
		push_error("Failed to decode image bytes (error %d)" % err)
		return null
	img.convert(Image.FORMAT_RGB8)
	return img


static func pixelate(source: Image, pixel_size: int, color_levels: int = 32) -> Image:
	var img := crop_to_square(source)

	var side := img.get_width()

	# Downscale
	var target := clampi(side / pixel_size, 32, 128)

	img.resize(
		target,
		target,
		Image.INTERPOLATE_LANCZOS
	)

	# Slight contrast
	img.adjust_bcs(
		1.25, # brightness
		1.15, # contrast
		0.95  # saturation
	)

	_quantize(img, color_levels)

	img.resize(
		side,
		side,
		Image.INTERPOLATE_NEAREST
	)

	return img


static func _quantize(img: Image, levels: int) -> void:
	var step := 255.0 / float(levels - 1)

	for y in range(img.get_height()):
		for x in range(img.get_width()):

			var c: Color = img.get_pixel(x, y)

			var r: float = round(c.r * 255.0 / step) * step / 255.0
			var g: float = round(c.g * 255.0 / step) * step / 255.0
			var b: float = round(c.b * 255.0 / step) * step / 255.0

			img.set_pixel(x, y, Color(r, g, b))


static func crop_to_square(image: Image) -> Image:

	var side: int = mini(
		image.get_width(),
		image.get_height()
	)

	var x: int = (image.get_width() - side) / 2
	var y: int = (image.get_height() - side) / 2

	var square: Image = Image.create(
		side,
		side,
		false,
		image.get_format()
	)

	square.blit_rect(
		image,
		Rect2i(x, y, side, side),
		Vector2i.ZERO
	)

	return square


static func to_texture(img: Image) -> ImageTexture:
	return ImageTexture.create_from_image(img)
