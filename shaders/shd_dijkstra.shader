attribute vec3 in_Position; 
attribute vec2 in_TextureCoord; 

varying vec2 v_Texcoord;

void main()
{
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);
    
    v_Texcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~varying vec2 v_Texcoord;

uniform vec4 uBlankColor;
uniform vec2 uCellSize;
uniform sampler2D uObstacles;

const float obstacleHeight = 16777216.0;
const float maxValue = 4294967296.0;

//Thanks!
//http://stackoverflow.com/questions/18453302/how-do-you-pack-one-32bit-int-into-4-8bit-ints-in-glsl-webgl
const vec4 bitSh = vec4(256. * 256. * 256., 256. * 256., 256., 1.);
const vec4 bitMsk = vec4(0.,vec3(1./256.0));
const vec4 bitShifts = vec4(1.) / bitSh;

vec4 pack (float depth) {
    /*vec4 comp = fract(depth * bitSh);
    comp -= comp.xxyz * bitMsk;
    return comp;*/
    return vec4(depth / 256.0, 0.0, 0.0, 1.0);
}
float unpack (vec4 color) {
    //return dot(color , bitShifts);
    return color.x * 256.0;
}

void main()
{
    vec4 currentColor = texture2D(gm_BaseTexture, v_Texcoord);
    float currentObstacle = texture2D(uObstacles, v_Texcoord).r;
    
    vec2 offsets[4];
        offsets[0] = vec2(-1.0,  0.0);
        offsets[1] = vec2(+1.0,  0.0);
        offsets[2] = vec2( 0.0, -1.0);
        offsets[3] = vec2( 0.0, +1.0);
        
    vec4 colors[4];
        colors[0] = texture2D(gm_BaseTexture, v_Texcoord + uCellSize * offsets[0]);
        colors[1] = texture2D(gm_BaseTexture, v_Texcoord + uCellSize * offsets[1]);
        colors[2] = texture2D(gm_BaseTexture, v_Texcoord + uCellSize * offsets[2]);
        colors[3] = texture2D(gm_BaseTexture, v_Texcoord + uCellSize * offsets[3]);
        
    //Is an obstacle
    if(currentObstacle != 0.0) {
        gl_FragColor = currentColor;
        return;
    }
        
    //Closed already
    if(currentColor != uBlankColor) {
        gl_FragColor = currentColor;
        return;
    }
     
    //Blank itself, all neighbors blank -> not opened yet 
    if(colors[0] == uBlankColor && colors[1] == uBlankColor && colors[2] == uBlankColor && colors[3] == uBlankColor){
        gl_FragColor = currentColor;
        return;
    }
        
    float obstacles[4]; 
        obstacles[0] = texture2D(uObstacles, v_Texcoord + uCellSize * offsets[0]).r * obstacleHeight;
        obstacles[1] = texture2D(uObstacles, v_Texcoord + uCellSize * offsets[1]).r * obstacleHeight;
        obstacles[2] = texture2D(uObstacles, v_Texcoord + uCellSize * offsets[2]).r * obstacleHeight;
        obstacles[3] = texture2D(uObstacles, v_Texcoord + uCellSize * offsets[3]).r * obstacleHeight;
    
    float values[4];
        values[0] = unpack(colors[0]) + obstacles[0];
        values[1] = unpack(colors[1]) + obstacles[1];
        values[2] = unpack(colors[2]) + obstacles[2];
        values[3] = unpack(colors[3]) + obstacles[3];
        
    float minValue = maxValue;
        if(colors[0] != uBlankColor && obstacles[0] == 0.0)
            minValue = min(values[0], minValue);
            
        if(colors[1] != uBlankColor && obstacles[1] == 0.0)
            minValue = min(values[1], minValue);
            
        if(colors[2] != uBlankColor && obstacles[2] == 0.0)
            minValue = min(values[2], minValue);
            
        if(colors[3] != uBlankColor && obstacles[3] == 0.0)
            minValue = min(values[3], minValue);
    
    gl_FragColor = pack(minValue + 1.0);
}

