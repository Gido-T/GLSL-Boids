const float EDGE_SIZE = 0.005;
const float PI = 3.1415926535;

struct RightTriangle {
    float hyp;
    float xComp;
    float yComp;
};

// Thank you Inigo Quilez
float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return smoothstep(0., 0.005, length( pa - ba*h ));
}

RightTriangle rTri(vec2 uv, vec2 a, vec2 b) {
    float hypot = sdSegment(uv, b, a);
    float xComp = sdSegment(uv, a, vec2(b.x, 0));
    float yComp = sdSegment(uv, vec2(b.x,0), b);
    
    return RightTriangle(
       hypot,
       xComp,
       yComp
    );
}

vec2 rotate(vec2 uv, float theta) {
    return mat2(
        cos(theta), sin(theta),
        -sin(theta), cos(theta)
    ) * uv;
}

float sdCircle(vec2 uv, float r) {
    float d = length(uv) - r;
    return smoothstep(0., 0.05, d);
}


// Taken from https://iquilezles.org/articles/distfunctions2d/ and modified a bit
float sdTriangleIsosceles( in vec2 p, in vec2 q )
{
    p.x = abs(p.x);
    vec2 a = p - q*clamp( dot(p,q)/dot(q,q), 0.0, 1.0 );
    vec2 b = p - q*vec2( clamp( p.x/q.x, 0.0, 1.0 ), 1.0 );
    float s = -sign( q.y );
    vec2 d = min( vec2( dot(a,a), s*(p.x*q.y-p.y*q.x) ),
                  vec2( dot(b,b), s*(p.y-q.y)  ));
    float df = -sqrt(d.x)*sign(d.y);
    df = abs(df) + 0.001;
    return smoothstep(0., EDGE_SIZE, df);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord/iResolution.xy)-0.5;
    uv.x *= iResolution.x/iResolution.y;
    
    vec3 col = vec3(0.15);
    
    vec2 oldUV = uv;
    for(float i = 0.; i < BIRD_COUNT; i++) {
        uv -= texelFetch(iChannel0, ivec2(i, 0.), 0).xy;
        
        float circle = sdCircle(uv, VIEW_DISTANCE);
        
        col = mix(vec3(0.2), col, circle);
        uv = oldUV;
    }
    
    for(float i = 0.; i < BIRD_COUNT; i++) {
        vec2 dir = texelFetch(iChannel0, ivec2(i,0.), 0).zw;
        vec2 offset = texelFetch(iChannel0, ivec2(i, 0.), 0).xy;
        
        uv -= offset; 
        //RightTriangle tri = rTri(uv, vec2(0.), (dir/length(dir)) * SPEED * 5.);
        //col = mix(vec3(0,1,0), col, tri.yComp);
        //col = mix(vec3(1,0,0), col, tri.xComp);
        //col = mix(vec3(0,0,1), col, tri.hyp);
        
        uv = rotate(uv, atan(dir.x, dir.y) - PI);

        float triangle = sdTriangleIsosceles(uv, vec2(0.015,0.04));
        
        col = mix(vec3(1., 0, 0.3 + i/BIRD_COUNT), col, triangle);
        
        
        uv = oldUV;
    }
    

    fragColor = vec4(col,1.0);
}
