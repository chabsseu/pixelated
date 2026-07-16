extends Node
class_name PixelateUtil

## Loads an image from a file path and returns a pixelated ImageTexture.
## grid_size = how many blocks across/down (e.g. 24 = 24x24 blocks -> lower = chunkier/harder)
## color_levels = how many shades PER CHANNEL to keep (e.g. 4-6 gives a flat "pixel art" palette,
##                255 = no color reduction, just blockiness)

static func load_image_from_path(path: String) -> Image:
	var img := Image.new()
	var err := img.load(path)
	if err != OK:
		push_error("Failed to load image at %s (error %d)" % [path, err])
		return null
	img.convert(Image.FORMAT_RGB8)
	return img

static func pixelate(source: Image, grid_size: int, color_levels: int = 255) -> Image:
	var w := source.get_width()
	var h := source.get_height()

	# Work on a square-ish crop from the center so pieces slice evenly later.
	var side: int = min(w, h)
	var crop_x := int((w - side) / 2.0)
	var crop_y := int((h - side) / 2.0)
	var cropped := source.get_region(Rect2i(crop_x, crop_y, side, side))

	# Step 1: shrink down to grid_size x grid_size.
	# Godot's INTERPOLATE_LANCZOS/BILINEAR average pixels together (avoids noisy/blotchy
	# single-pixel sampling you'd get from NEAREST on the downscale).
	cropped.resize(grid_size, grid_size, Image.INTERPOLATE_BILINEAR)

	# Step 2: optional color quantization for a clean flat "pixel art" look
	# instead of a muddy photographic gradient.
	if color_levels < 255:
		_quantize(cropped, color_levels)

	# Step 3: scale back up with NEAREST so blocks stay crisp (no blur).
	cropped.resize(side, side, Image.INTERPOLATE_NEAREST)
	return cropped

static func _quantize(img: Image, levels: int) -> void:
	# Reduces each color channel down to `levels` discrete steps.
	# e.g. levels = 6 -> each channel snaps to one of 6 values (0, 51, 102, ...255)
	# Note: Godot 4 images no longer need lock()/unlock() before get_pixel/set_pixel.
	var w := img.get_width()
	var h := img.get_height()
	var step := 255.0 / float(levels - 1)
	for y in range(h):
		for x in range(w):
			var c: Color = img.get_pixel(x, y)
			var r: float = round(round(c.r * 255.0 / step) * step) / 255.0
			var g: float = round(round(c.g * 255.0 / step) * step) / 255.0
			var b: float = round(round(c.b * 255.0 / step) * step) / 255.0
			img.set_pixel(x, y, Color(r, g, b, c.a))

static func to_texture(img: Image) -> ImageTexture:
	# Godot 4: ImageTexture.create_from_image() is a static factory method.
	return ImageTexture.create_from_image(img)
