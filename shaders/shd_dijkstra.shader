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
	float currentValue = unpack(currentColor);
    float currentObstacle = texture2D(uObstacles, v_Texcoord).r;
    
	vec2 offsets[8];
		offsets[0] = vec2(-1.0, -1.0); 
		offsets[1] = vec2(0.0, -1.0); 
		offsets[2] = vec2(1.0, -1.0); 
		offsets[3] = vec2(-1.0, 0.0); 
		offsets[4] = vec2(1.0, 0.0); 
		offsets[5] = vec2(-1.0, 1.0); 
		offsets[6] = vec2(0.0, 1.0); 
		offsets[7] = vec2(1.0, 1.0); 

	float weights[8];
		weights[0] = 1.4142; 
		weights[1] = 1.0000; 
		weights[2] = 1.4142; 
		weights[3] = 1.0000; 
		weights[4] = 1.0000; 
		weights[5] = 1.4142; 
		weights[6] = 1.0000; 
		weights[7] = 1.4142; 

	vec4 colors[8];
		colors[0] = texture2D(gm_BaseTexture, v_Texcoord + uCellSize * offsets[0]); 
		colors[1] = texture2D(gm_BaseTexture, v_Texcoord + uCellSize * offsets[1]); 
		colors[2] = texture2D(gm_BaseTexture, v_Texcoord + uCellSize * offsets[2]); 
		colors[3] = texture2D(gm_BaseTexture, v_Texcoord + uCellSize * offsets[3]); 
		colors[4] = texture2D(gm_BaseTexture, v_Texcoord + uCellSize * offsets[4]); 
		colors[5] = texture2D(gm_BaseTexture, v_Texcoord + uCellSize * offsets[5]); 
		colors[6] = texture2D(gm_BaseTexture, v_Texcoord + uCellSize * offsets[6]); 
		colors[7] = texture2D(gm_BaseTexture, v_Texcoord + uCellSize * offsets[7]); 
        
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
	if(colors[0] == uBlankColor && colors[1] == uBlankColor && colors[2] == uBlankColor && colors[3] == uBlankColor && colors[4] == uBlankColor && colors[5] == uBlankColor && colors[6] == uBlankColor && colors[7] == uBlankColor) {
		gl_FragColor = currentColor;
		return; }
        
    //
    
	float obstacles[8];
		obstacles[0] = texture2D(uObstacles, v_Texcoord + uCellSize * offsets[0]).r * obstacleHeight; 
		obstacles[1] = texture2D(uObstacles, v_Texcoord + uCellSize * offsets[1]).r * obstacleHeight; 
		obstacles[2] = texture2D(uObstacles, v_Texcoord + uCellSize * offsets[2]).r * obstacleHeight; 
		obstacles[3] = texture2D(uObstacles, v_Texcoord + uCellSize * offsets[3]).r * obstacleHeight; 
		obstacles[4] = texture2D(uObstacles, v_Texcoord + uCellSize * offsets[4]).r * obstacleHeight; 
		obstacles[5] = texture2D(uObstacles, v_Texcoord + uCellSize * offsets[5]).r * obstacleHeight; 
		obstacles[6] = texture2D(uObstacles, v_Texcoord + uCellSize * offsets[6]).r * obstacleHeight; 
		obstacles[7] = texture2D(uObstacles, v_Texcoord + uCellSize * offsets[7]).r * obstacleHeight; 
    
	float values[8];
		values[0] = unpack(colors[0])*weights[0] + obstacles[0]; 
		values[1] = unpack(colors[1])*weights[1] + obstacles[1]; 
		values[2] = unpack(colors[2])*weights[2] + obstacles[2]; 
		values[3] = unpack(colors[3])*weights[3] + obstacles[3]; 
		values[4] = unpack(colors[4])*weights[4] + obstacles[4]; 
		values[5] = unpack(colors[5])*weights[5] + obstacles[5]; 
		values[6] = unpack(colors[6])*weights[6] + obstacles[6]; 
		values[7] = unpack(colors[7])*weights[7] + obstacles[7]; 
        
    float minValue = maxValue;
	float stepWeight = 0.0;
		if(colors[0] != uBlankColor && obstacles[0] == 0.0) {
			minValue = min(values[0], minValue);
			stepWeight=weights[0];
		}
		if(colors[1] != uBlankColor && obstacles[1] == 0.0) {
			minValue = min(values[1], minValue);
			stepWeight=weights[1];
		}
		if(colors[2] != uBlankColor && obstacles[2] == 0.0) {
			minValue = min(values[2], minValue);
			stepWeight=weights[2];
		}
		if(colors[3] != uBlankColor && obstacles[3] == 0.0) {
			minValue = min(values[3], minValue);
			stepWeight=weights[3];
		}
		if(colors[4] != uBlankColor && obstacles[4] == 0.0) {
			minValue = min(values[4], minValue);
			stepWeight=weights[4];
		}
		if(colors[5] != uBlankColor && obstacles[5] == 0.0) {
			minValue = min(values[5], minValue);
			stepWeight=weights[5];
		}
		if(colors[6] != uBlankColor && obstacles[6] == 0.0) {
			minValue = min(values[6], minValue);
			stepWeight=weights[6];
		}
		if(colors[7] != uBlankColor && obstacles[7] == 0.0) {
			minValue = min(values[7], minValue);
			stepWeight=weights[7];
		}
    gl_FragColor = pack(minValue + stepWeight);
}

