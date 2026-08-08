shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;


// ============================================================
// BLOOM
// ============================================================

uniform float bloom_intensity : hint_range(0.0, 3.0) = 0.8;
uniform float bloom_threshold : hint_range(0.0, 2.0) = 0.7;
uniform float bloom_radius : hint_range(0.0, 5.0) = 2.0;


// ============================================================
// VIGNETTE
// ============================================================

uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.35;
uniform float vignette_radius : hint_range(0.0, 1.5) = 0.75;
uniform float vignette_softness : hint_range(0.01, 1.0) = 0.45;


// ============================================================
// CHROMATIC ABERRATION
// ============================================================

uniform float chromatic_aberration : hint_range(0.0, 0.05) = 0.003;


// ============================================================
// FILM GRAIN
// ============================================================

uniform float film_grain : hint_range(0.0, 0.2) = 0.02;
uniform float grain_speed : hint_range(0.0, 10.0) = 1.0;


// ============================================================
// COLOR
// ============================================================

uniform float brightness : hint_range(0.0, 2.0) = 1.0;
uniform float contrast : hint_range(0.0, 2.0) = 1.0;
uniform float saturation : hint_range(0.0, 2.0) = 1.0;


// ============================================================
// SCANLINES
// ============================================================

uniform float scanlines : hint_range(0.0, 1.0) = 0.0;
uniform float scanline_density : hint_range(50.0, 1000.0) = 400.0;


// ============================================================
// RANDOM
// ============================================================

float random(vec2 uv)
{
    return fract(
        sin(dot(uv, vec2(12.9898, 78.233)))
        * 43758.5453123
    );
}


// ============================================================
// BLOOM
// ============================================================

vec3 get_bloom(vec2 uv)
{
    vec2 pixel = 1.0 / vec2(textureSize(screen_texture, 0));

    vec2 offset_x = vec2(pixel.x * bloom_radius, 0.0);
    vec2 offset_y = vec2(0.0, pixel.y * bloom_radius);

    vec2 offset_xy = vec2(
        pixel.x * bloom_radius,
        pixel.y * bloom_radius
    );

    vec3 bloom = vec3(0.0);

    // Center
    bloom += texture(
        screen_texture,
        uv
    ).rgb * 0.16;

    // Horizontal
    bloom += texture(
        screen_texture,
        uv + offset_x
    ).rgb * 0.12;

    bloom += texture(
        screen_texture,
        uv - offset_x
    ).rgb * 0.12;

    // Vertical
    bloom += texture(
        screen_texture,
        uv + offset_y
    ).rgb * 0.12;

    bloom += texture(
        screen_texture,
        uv - offset_y
    ).rgb * 0.12;

    // Diagonal
    bloom += texture(
        screen_texture,
        uv + offset_xy
    ).rgb * 0.08;

    bloom += texture(
        screen_texture,
        uv + vec2(
            -offset_xy.x,
            offset_xy.y
        )
    ).rgb * 0.08;

    bloom += texture(
        screen_texture,
        uv + vec2(
            offset_xy.x,
            -offset_xy.y
        )
    ).rgb * 0.08;

    bloom += texture(
        screen_texture,
        uv - offset_xy
    ).rgb * 0.08;


    // Brightness threshold
    float brightness_value = dot(
        bloom,
        vec3(
            0.2126,
            0.7152,
            0.0722
        )
    );

    float threshold = smoothstep(
        bloom_threshold,
        bloom_threshold + 0.2,
        brightness_value
    );

    bloom *= threshold;

    return bloom;
}


// ============================================================
// MAIN
// ============================================================

void fragment()
{
    vec2 uv = SCREEN_UV;


    // ========================================================
    // ORIGINAL IMAGE
    // ========================================================

    vec3 color = texture(
        screen_texture,
        uv
    ).rgb;


    // ========================================================
    // BLOOM
    // ========================================================

    vec3 bloom = get_bloom(uv);

    color += bloom * bloom_intensity;


    // ========================================================
    // CHROMATIC ABERRATION
    // ========================================================

    vec2 direction = uv - vec2(0.5);

    float distance_from_center =
        length(direction);

    vec2 offset =
        normalize(direction + vec2(0.00001))
        * chromatic_aberration
        * distance_from_center;

    float red = texture(
        screen_texture,
        uv + offset
    ).r;

    float green = texture(
        screen_texture,
        uv
    ).g;

    float blue = texture(
        screen_texture,
        uv - offset
    ).b;

    color.r = red;
    color.g = green;
    color.b = blue;


    // ========================================================
    // BRIGHTNESS
    // ========================================================

    color *= brightness;


    // ========================================================
    // CONTRAST
    // ========================================================

    color =
        (color - 0.5)
        * contrast
        + 0.5;


    // ========================================================
    // SATURATION
    // ========================================================

    float luminance = dot(
        color,
        vec3(
            0.299,
            0.587,
            0.114
        )
    );

    color = mix(
        vec3(luminance),
        color,
        saturation
    );


    // ========================================================
    // VIGNETTE
    // ========================================================

    vec2 vignette_uv =
        uv - vec2(0.5);

    vec2 pixel_size =
        1.0 / vec2(textureSize(screen_texture, 0));

    float aspect =
        pixel_size.y /
        pixel_size.x;

    vignette_uv.x *= aspect;

    float vignette_distance =
        length(vignette_uv);

    float vignette =
        smoothstep(
            vignette_radius,
            vignette_radius - vignette_softness,
            vignette_distance
        );

    vignette = 1.0 - vignette;

    color *=
        1.0 -
        vignette *
        vignette_intensity;


    // ========================================================
    // FILM GRAIN
    // ========================================================

    vec2 grain_uv =
        uv * 1000.0;

    grain_uv +=
        vec2(TIME * grain_speed);

    float noise =
        random(grain_uv);

    noise -= 0.5;

    color +=
        noise *
        film_grain;


    // ========================================================
    // SCANLINES
    // ========================================================

    float scanline =
        sin(
            uv.y *
            scanline_density
        );

    scanline =
        scanline * 0.5 +
        0.5;

    color *= mix(
        1.0,
        scanline,
        scanlines * 0.25
    );


    // ========================================================
    // OUTPUT
    // ========================================================

    color =
        max(color, vec3(0.0));

    COLOR =
        vec4(color, 1.0);
}