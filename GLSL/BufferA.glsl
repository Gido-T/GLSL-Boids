float TURN_RATIO = 0.05;
float CENTER_RATIO = 0.05;
float AVOID_RATIO = 0.05;
float MAX_Y = 0.5;
float MAX_X = 0.9;
float TURN_AMOUNT = 0.25;
float VISUAL_RANGE = 0.15;

float rand(float co) { return fract(sin(co*(91.3458)) * 47453.5453); }
vec2 hash(float n) { return fract(sin(vec2(n,n*7.))*43758.5); }

void mainImage( out vec4 fragColor, in vec2 uv )
{
    float id = floor(uv.x);
    vec2 offset = texelFetch(iChannel0, ivec2(id, 0.), 0).xy;
    vec2 direction = texelFetch(iChannel0, ivec2(id,0.), 0).zw;
    
    if (iFrame == 0) {
        direction = rand(id + 1.) * vec2(0.1,0.1);
        offset += vec2(rand(id + 1.)-0.5, 0.);
    }
    
    
    if(offset.x >= MAX_X) {
        direction.x -= TURN_AMOUNT;
    } else if(offset.x <= -MAX_X) {
        direction.x += TURN_AMOUNT;
    }
    
    if(offset.y >= MAX_Y) {
        direction.y -= TURN_AMOUNT;
    } else if(offset.y <= -MAX_Y) {
        direction.y += TURN_AMOUNT;
    }
    
    vec2 move = vec2(0.,0.);
    vec2 center = vec2(0., 0.);
    
    float numNeighbors = 0.;
    
    for(float i = 0.; i < BIRD_COUNT; i++) {
        vec2 oBirdOff = texelFetch(iChannel0, ivec2(i, 0.), 0).xy;
        if(i != id && length(offset - oBirdOff) < VIEW_DISTANCE) {
            move += offset - oBirdOff;
        } 
        
        if(length(offset - oBirdOff) < VISUAL_RANGE) {
           center += oBirdOff;
           numNeighbors += 1.;
        }
    }
    
    if(numNeighbors > 0.) {
        center /= numNeighbors;
        
        // Have boid move toward center
        direction += (center - offset) * CENTER_RATIO;
        
        // Have boid match neighbor velocity
        direction += (center - direction - offset) * AVOID_RATIO;
    }
    
    direction += move * TURN_RATIO;
    direction = (direction / length(direction)) * SPEED;
    
    offset += direction;    
    fragColor = vec4(offset,direction);
}
