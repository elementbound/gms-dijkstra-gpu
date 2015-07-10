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

<?php
	$offsets = array();
	$weights = array();
	for($i=0; $i<9; $i++) {
		$x = $i % 3;
		$y = ($i-$x)/3;
		
		$x--; $y--;
		
		if($x == 0 && $y == 0)
			continue;
		
		/*if($x != 0 && $y != 0)
			continue;*/
		
		$offsets[] = array($x, $y);
	}
	
	foreach($offsets as $off) {
		$weights[] = sqrt($off[0]*$off[0] + $off[1]*$off[1]);
	}
?>

void main()
{
    vec4 currentColor = texture2D(gm_BaseTexture, v_Texcoord);
	float currentValue = unpack(currentColor);
    float currentObstacle = texture2D(uObstacles, v_Texcoord).r;
    
	<?php 
	printf("vec2 offsets[%d];\n", count($offsets));
	foreach($offsets as $i => $v) {
		printf("\t\toffsets[%d] = vec2(%.1f, %.1f); \n", $i, $v[0], $v[1]);
	}
	
	printf("\n\tfloat weights[%d];\n", count($weights));
	foreach($weights as $i => $v) {
		printf("\t\tweights[%d] = %.4f; \n", $i, $v);
	}
	
	printf("\n\tvec4 colors[%d];\n", count($offsets));
	for($i=0; $i<count($offsets); $i++) 
		printf("\t\tcolors[%d] = texture2D(gm_BaseTexture, v_Texcoord + uCellSize * offsets[%d]); \n", $i, $i);
	?>
        
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
<?php 
	$bs = count($offsets);
	for($i=0; $i<count($offsets); $i+=$bs) {
		print "\tif(";
		for($j=$i; $j<$i+$bs; $j++) {
			if($i != $j) print " && ";
			print "colors[$j] == uBlankColor";
		}
		
		print ") {\n".
			  "\t\tgl_FragColor = currentColor;\n".
			  "\t\treturn; }\n";
	}
	?>
        
    //
    
	<?php 
		print "float obstacles[".count($offsets)."];\n";
		foreach($offsets as $i => $v) 
			print "\t\tobstacles[$i] = texture2D(uObstacles, v_Texcoord + uCellSize * offsets[$i]).r * obstacleHeight; \n";
	?>
    
	<?php
		print "float values[".count($offsets)."];\n";
		foreach($offsets as $i => $v) 
			print "\t\tvalues[$i] = unpack(colors[$i])*weights[$i] + obstacles[$i]; \n";
	?>
        
    float minValue = maxValue;
	float stepWeight = 0.0;
<?php
	for($i=0; $i<count($offsets); $i++) {
		print "\t\tif(colors[$i] != uBlankColor && obstacles[$i] == 0.0) {\n".
			  "\t\t\tminValue = min(values[$i], minValue);\n".
			  "\t\t\tstepWeight=weights[$i];\n".
			  "\t\t}\n";
	}
?>
    gl_FragColor = pack(minValue + stepWeight);
}

