shader_type canvas_item;

uniform int pixel_size : hint_range(1, 64) = 8;
uniform int color_levels : hint_range(2, 64) = 16;

void fragment()
{
    vec2 tex_size = vec2(textureSize(TEXTURE, 0));

    // Pixelation
    vec2 pixel = floor(UV * tex_size / float(pixel_size));
    vec2 uv = (pixel * float(pixel_size)) / tex_size;

    vec4 color = texture(TEXTURE, uv);

    // Posterize colors
    float levels = float(color_levels);

    color.rgb = floor(color.rgb * levels) / levels;

    COLOR = color;
}