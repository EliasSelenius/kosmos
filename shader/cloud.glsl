

IO FragData {
    vec2 uv;
} v2f;

#include "../grax/shaders/scq.glsl"
#include "../grax/shaders/common.glsl"
#include "../grax/shaders/camera.glsl"
#include "../grax/shaders/lights.glsl"
#include "../grax/shaders/noise.glsl"


#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform vec3 camera_pos;

layout(binding = 0) uniform sampler2D g_buffer_pos;
layout(binding = 1) uniform sampler2D g_buffer_normal;
layout(binding = 2) uniform sampler2D g_buffer_albedo;

out vec4 FragColor;

bool ray_sphere_intersects(vec3 o, vec3 d, vec3 c, float radius, inout float dist) {
    float delta = sq(dot(d, o - c)) - (sq(length(o - c)) - sq(radius));

    dist = -dot(d, o - c) - sqrt(delta);

    return delta >= 0 && dist >= 0;
}

vec2 ray_aabb_intersects(vec3 o, vec3 r, vec3 l, vec3 h) {
    vec3 t_low  = (l - o) / r;
    vec3 t_high = (h - o) / r;
    vec3 t_close = min(t_low, t_high);
    vec3 t_far   = max(t_low, t_high);

    return vec2(max_axis(t_close), min_axis(t_far));
}

float density(vec3 p) {
    float d = (noise(p * 0.1) + 1.0) / 2.0;
    return d;
}

void main() {

    // TODO: paremeterize these
    float near_plane = 0.1;
    float far_plane = 10000.0;
    float fov = 90.0 * deg2rad;

    float half_near_plane_height = near_plane / tan(Half_Pi - fov / 2.0);
    float half_near_plane_width  = half_near_plane_height * (16.0 / 9.0);

    vec2 ndc = v2f.uv*2.0 - vec2(1.0);

    mat4 m = transpose(camera.view);
    vec3 left    = m[0].xyz; //  vec3(m[0], m[1], m[2]);
    vec3 up      = m[1].xyz; //  vec3(m[4], m[5], m[6]);
    vec3 forward = m[2].xyz; //  vec3(m[8], m[9], m[10]);
    // vec3 cam_pos = vec3(m[0][3], m[1][3], m[2][3]);


    vec3 ray = normalize(left * ndc.x * half_near_plane_width +
                         up * ndc.y * half_near_plane_height +
                         forward * -near_plane);


    discard;

    // {
    //     vec3 o = camera_pos;
    //     vec3 r = ray;

    //     vec3 bb = vec3(30.0);
    //     vec2 ts = ray_aabb_intersects(o, r, -bb, bb);

    //     vec3 p_close = o + ts.x * r;
    //     vec3 p_far   = o + ts.y * r;

    //     if (ts.x <= 0.0) p_close = o;

    //     if (ts.x <= ts.y && ts.x > 0.0) {

    //         float absorption = 0.05;
    //         // float dist = ts.y - ts.x;
    //         float dist = distance(p_close, p_far);

    //         float total = 0.0;
    //         for (int i = 0; i < 10; i++) {
    //             vec3 p = mix(p_close, p_far, float(i) / 10.0);
    //             float d = density(p);
    //             if (d < 0.5) d = 0;
    //             total += d*0.1;
    //         }

    //         FragColor = vec4(vec3(1.0), clamp(total, 0.0, 1.0));
    //         gl_FragDepth = get_fragdepth_from_world_space_point(p_close);
    //     } else {
    //         discard;
    //     }
    // }

    // { // edge detection
    //     vec3 albedo = texture(g_buffer_albedo, v2f.uv).rgb;
    //     vec3 albedo1 = texture(g_buffer_albedo, v2f.uv + 0.002).rgb;

    //     vec3 normal = texture(g_buffer_normal, v2f.uv).rgb;
    //     vec3 normal1 = texture(g_buffer_normal, v2f.uv + 0.002 * -normal.xy).rgb;

    //     //length(albedo - albedo1) > 0.01

    //     if (normal != vec3(0.0) && dot(normal, normal1) < 0.9) {
    //         FragColor = vec4(vec3(0.0), 1.0);
    //     } else {
    //         FragColor = vec4(0.0);
    //         discard;
    //     }
    // }


    // {
    //     vec3 pos = texture(g_buffer_pos, v2f.uv).xyz;
    //     float depth = length(pos);
    //     float traced = 0;
    //     float acc = 0;
    //     for (int i = 1; i <= 20; i++) {
    //         vec3 p = camera_pos + ray * float(i) * 10;
    //         acc += density(p) * 0.05;
    //         // if (length(ray * float(i)) > depth) break;
    //     }
    //     FragColor = vec4(vec3(1.0, 0, 0), acc);
    // }

    // {
    //     float sphere_radius = 1000;
    //     vec3 sphere_pos = vec3(0.0, 0.0, sphere_radius + 10);

    //     float dist;
    //     if (ray_sphere_intersects(camera_pos, ray, sphere_pos, sphere_radius, dist)) {

    //         vec3 point = camera_pos + ray * dist;
    //         vec3 normal = normalize(point - sphere_pos);

    //         gl_FragDepth = get_fragdepth_from_world_space_point(point);

    //         Geometry g;
    //         g.pos = (camera.view * vec4(point, 1.0)).xyz;
    //         g.normal = mat3(camera.view) * normal;
    //         g.albedo = vec3(1.0);
    //         g.roughness = 0.5;
    //         g.metallic = 0.9;

    //         vec3 light = calc_dir_light(camera.sun_dir.xyz, camera.sun_radiance.xyz, g);
    //         FragColor = vec4(light, 1.0);

    //     } else {
    //         discard;
    //         // FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    //     }
    // }

}

#endif