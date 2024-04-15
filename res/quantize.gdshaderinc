/*
 * This is the quantize shader-include file. Please make a copy in a
 * separate file, and update the #include in the dither shader-include to match.
*/

uniform float quantize_size : hint_range(0,100, 1.0) = 1;
// Determines how scaled images should display
uniform bool handle_scale;

varying mat4 g_model_matrix;
varying mat4 g_world_to_clip;
varying vec2 g_texture_size;
varying vec2 g_vertex;
varying flat vec2 g_flat_vertex;

vec4 quantizeTexture(
    sampler2D in_texture,
    vec2 in_uv,
    out vec2 out_world_vertex
) {
    if (quantize_size == 0.) {
        out_world_vertex = (g_model_matrix * vec4(in_uv * g_texture_size, 0, 1)).xy;
        return texture(in_texture, in_uv);
    }

    // gets -1 if not flipped, 1 if flipped
    vec2 flipped = sign(g_flat_vertex - g_vertex);
    // gets the offset of the texture
    // adds 1 when flipped
    vec2 offset = g_flat_vertex / g_texture_size;

    vec2 uv = in_uv;
    // add offset so positioned back at 0,0 locally
    // so grid lines up
    uv *= flipped;
    uv = offset - uv;
    // scale to texture size
    uv *= g_texture_size;

    if (handle_scale) { // convert to world space
        uv = (g_model_matrix * vec4(uv, 0, 1)).xy;
    }

    out_world_vertex = uv;
    // quantize to specified pixel size
    uv /= quantize_size;
    uv = floor(uv) + 0.5;
    uv *= quantize_size;

    if (handle_scale) { // convert back to local space
        uv = (inverse(g_model_matrix) * vec4(uv, 0, 1)).xy;
    }

    // normalize
    uv /= g_texture_size;
    // remove offset so pixel taken at correct location
    uv = offset - uv;
    uv *= flipped;
    return texture(in_texture, uv);
}

vec4 quantizeScreen(
    sampler2D in_screen_texture,
    vec2 in_screen_uv,
    vec2 in_vertex,
    out vec2 out_world_vertex
) {
    out_world_vertex = (g_model_matrix * vec4(in_vertex, 0, 1)).xy;

    if (quantize_size == 0.) {
        return texture(in_screen_texture, in_screen_uv);
    }

    vec2 uv = out_world_vertex;
    uv /= quantize_size;
    uv = floor(uv) + 0.5;
    uv *= quantize_size;
    uv = (g_world_to_clip * vec4(uv, 0, 1)).xy;
    uv = uv * 0.5 + 0.5;
    return texture(in_screen_texture, uv);
}