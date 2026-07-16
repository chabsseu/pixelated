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


static func pixelate(source: Image, pixel_size: int, color_levels: int = 255) -> Image:

	var width: int = source.get_width()
	var height: int = source.get_height()

	var side: int = mini(width, height)

	var crop_x: int = (width - side) / 2
	var crop_y: int = (height - side) / 2

	var img: Image = source.get_region(
		Rect2i(crop_x, crop_y, side, side)
	)

	# Improve the image before pixelating
	img.adjust_bcs(1.15, 1.08, 1.05)

	pixel_size = maxi(pixel_size, 1)

	var target: int = maxi(24, side / pixel_size)

	img.resize(
		target,
		target,
		Image.INTERPOLATE_LANCZOS
	)

	if color_levels < 255:
		_quantize(img, color_levels)

	img.resize(
		side,
		side,
		Image.INTERPOLATE_NEAREST
	)

	return img


static func _quantize(img: Image, levels: int) -> void:

	levels = maxi(levels, 2)

	var w: int = img.get_width()
	var h: int = img.get_height()

	var step: float = 255.0 / float(levels - 1)

	for y: int in range(h):
		for x: int in range(w):

			var c: Color = img.get_pixel(x, y)

			var rf: float = c.r * 255.0
			var gf: float = c.g * 255.0
			var bf: float = c.b * 255.0

			var r_step: int = int(round(rf / step))
			var g_step: int = int(round(gf / step))
			var b_step: int = int(round(bf / step))

			var r: float = float(r_step) * step / 255.0
			var g: float = float(g_step) * step / 255.0
			var b: float = float(b_step) * step / 255.0

			img.set_pixel(
				x,
				y,
				Color(r, g, b, c.a)
			)


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