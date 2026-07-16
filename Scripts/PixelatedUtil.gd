extends Node
class_name PixelateUtil

## Loads an image from disk.
static func load_image_from_path(path: String) -> Image:
	var img := Image.new()
	var err := img.load(path)
	if err != OK:
		push_error("Failed to load image at %s (error %d)" % [path, err])
		return null

	img.convert(Image.FORMAT_RGB8)
	return img


## Pixelates an image.
## pixel_size:
##     4  = very detailed
##     8  = recommended
##     12 = retro
##     16 = chunky
##
## color_levels:
##     255 = keep original colors
##     64  = light reduction
##     32  = SNES style
##     16  = retro
##      4  = GameBoy
static func pixelate(source: Image, pixel_size: int, color_levels: int = 255) -> Image:
	var width: int = source.get_width()
	var height: int = source.get_height()

	# Crop to a centered square
	var side: int = min(width, height)

	var crop_x: int = int((width - side) / 2)
	var crop_y: int = int((height - side) / 2)

	var cropped: Image = source.get_region(
		Rect2i(crop_x, crop_y, side, side)
	)

	# Prevent division by zero
	pixel_size = max(pixel_size, 1)

	# Calculate the downscaled resolution
	var target_size: int = max(8, int(side / pixel_size))

	# Downscale
	cropped.resize(
		target_size,
		target_size,
		Image.INTERPOLATE_BILINEAR
	)

	# Optional color reduction
	if color_levels < 255:
		_quantize(cropped, color_levels)

	# Upscale with crisp pixels
	cropped.resize(
		side,
		side,
		Image.INTERPOLATE_NEAREST
	)

	return cropped

static func _quantize(img: Image, levels: int) -> void:
	levels = max(levels, 2)

	var w: int = img.get_width()
	var h: int = img.get_height()

	var step: float = 255.0 / float(levels - 1)

	for y in range(h):
		for x in range(w):
			var c: Color = img.get_pixel(x, y)

			var r: float = round(c.r * 255.0 / step) * step / 255.0
			var g: float = round(c.g * 255.0 / step) * step / 255.0
			var b: float = round(c.b * 255.0 / step) * step / 255.0

			img.set_pixel(
				x,
				y,
				Color(r, g, b, c.a)
			)


static func crop_to_square(image: Image) -> Image:
	var side: int = min(
		image.get_width(),
		image.get_height()
	)

	var x: int = int((image.get_width() - side) / 2)
	var y: int = int((image.get_height() - side) / 2)

	var square := Image.create(
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