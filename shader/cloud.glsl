
#include "../grax/shaders/common.glsl"
#include "../grax/shaders/camera.glsl"
#include "../grax/shaders/lights.glsl"
#include "../grax/shaders/noise.glsl"


uniform vec3 u_camera_pos;

layout(binding = 0) uniform sampler2D g_buffer_pos;
layout(binding = 1) uniform sampler2D g_buffer_normal;
layout(binding = 2) uniform sampler2D g_buffer_albedo;


#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void main() {
    gl_Position = screen_covering_quad(gl_VertexID);
}
#endif




#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
out vec4 FragColor;

float density(vec3 p) {
    float d = (noise(p * 0.1) + 1.0) / 2.0;
    return d;
}

void main() {
    vec2 screen_uv = gl_FragCoord.xy / ViewportSize;
    vec2 ndc = screen_uv*2.0 - 1.0;
    vec3 ray = camera_ray(ndc);

    vec3 view_pos = texture(g_buffer_pos, screen_uv).xyz;

    // discard;

    float dist = length(view_pos);

    // {
    //     vec3 o = u_camera_pos;
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
    //     vec3 albedo = texture(g_buffer_albedo, screen_uv).rgb;
    //     vec3 albedo1 = texture(g_buffer_albedo, screen_uv + 0.002).rgb;

    //     vec3 normal = texture(g_buffer_normal, screen_uv).rgb;
    //     vec3 normal1 = texture(g_buffer_normal, screen_uv + 0.002 * -normal.xy).rgb;

    //     //length(albedo - albedo1) > 0.01

    //     if (normal != vec3(0.0) && dot(normal, normal1) < 0.9) {
    //         FragColor = vec4(vec3(0.0), 1.0);
    //     } else {
    //         FragColor = vec4(0.0);
    //         discard;
    //     }
    // }


    // {
    //     vec3 pos = texture(g_buffer_pos, screen_uv).xyz;
    //     float depth = length(pos);
    //     float traced = 0;
    //     float acc = 0;
    //     for (int i = 1; i <= 20; i++) {
    //         vec3 p = u_camera_pos + ray * float(i) * 10;
    //         acc += density(p) * 0.05;
    //         // if (length(ray * float(i)) > depth) break;
    //     }
    //     FragColor = vec4(vec3(1.0, 0, 0), acc);
    // }

    // {
    //     float sphere_radius = 1000;
    //     vec3 sphere_pos = vec3(0.0, 0.0, sphere_radius + 10);

    //     float dist;
    //     if (ray_sphere_intersects(u_camera_pos, ray, sphere_pos, sphere_radius, dist)) {

    //         vec3 point = u_camera_pos + ray * dist;
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