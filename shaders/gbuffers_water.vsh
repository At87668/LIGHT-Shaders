#version 120

/*
!! DO NOT REMOVE !!
Original code is from Chocapic13' shaders and this code is modified by LIGHT Shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/



#define ENTITY_LEAVES        18.0
#define ENTITY_VINES        106.0
#define ENTITY_TALLGRASS     31.0
#define ENTITY_DANDELION     37.0
#define ENTITY_ROSE          38.0
#define ENTITY_WHEAT         59.0
#define ENTITY_LILYPAD      111.0
#define ENTITY_FIRE          51.0
#define ENTITY_LAVAFLOWING   10.0
#define ENTITY_LAVASTILL     11.0

varying vec4 color;
varying vec4 lmtexcoord;
varying vec3 sunlight;
varying vec3 binormal;
varying vec3 normal;
varying vec3 tangent;
varying float iswater;

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

uniform vec3 cameraPosition;
uniform vec3 sunPosition;
uniform vec3 upPosition;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform int worldTime;
uniform float frameTimeCounter;
uniform float sunAngle;
uniform float rainStrength;

const float PI = 3.1415927;



const vec3 ToD[7] = vec3[7](  vec3(0.58597,0.16,0.025),
								vec3(0.58597,0.4,0.2),
								vec3(0.58597,0.52344,0.24680),
								vec3(0.58597,0.55422,0.34),
								vec3(0.58597,0.57954,0.38),
								vec3(0.58597,0.58,0.40),
								vec3(0.58597,0.58,0.40));
								
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {

	


	/*--------------------------------*/
	
	
	//reduced the sun color to a 7 array
	float hour = max(mod(worldTime/1000.0+2.0,24.0)-2.0,0.0);  //6
	float cmpH = max(-abs(floor(hour)-6.0)+6.0,0.0); //6
	float cmpH1 = max(-abs(floor(hour)-5.0)+6.0,0.0); //1
	
	
	vec3 temp = ToD[int(cmpH)];
	vec3 temp2 = ToD[int(cmpH1)];
	
	sunlight = mix(temp,temp2,fract(hour));

	const vec3 rainC = vec3(0.005,0.007,0.009);
	sunlight = mix(sunlight,rainC*sunlight,rainStrength);
	
	lmtexcoord.xy = (gl_MultiTexCoord0).xy;
	lmtexcoord.zw = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

	
	vec4 position = gl_ModelViewMatrix * gl_Vertex;
	iswater = 0.0f;
	float displacement = 0.0;
	
	/* un-rotate */
	vec4 viewpos = gbufferModelViewInverse * position;

	vec3 worldpos = viewpos.xyz + cameraPosition;
	

	/*--------------------------------*/
	
		if(mc_Entity.x == 8.0 || mc_Entity.x == 9.0) {
		iswater = 1.0;
		float fy = fract(worldpos.y + 0.001);
		

		float wave = 0.05 * sin(2 * PI * (frameTimeCounter*0.75 + worldpos.x /  7.0 + worldpos.z / 13.0))
				   + 0.05 * sin(2 * PI * (frameTimeCounter*0.6 + worldpos.x / 11.0 + worldpos.z /  5.0));
		displacement = clamp(wave, -fy, 1.0-fy);
		viewpos.y += displacement*0.6-0.01;
	}
	if(mc_Entity.x == 79.0) iswater = 0.5;
	/* re-rotate */
	viewpos = gbufferModelView * viewpos;

	/* projectify */
	gl_Position = gl_ProjectionMatrix * viewpos;
	



	tangent = vec3(0.0);
	binormal = vec3(0.0);
	normal = normalize(gl_NormalMatrix * normalize(gl_Normal));

	if (gl_Normal.x > 0.5) {
		//  1.0,  0.0,  0.0
		tangent  = normalize(gl_NormalMatrix * vec3( 0.0,  0.0, -1.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	}
	
	else if (gl_Normal.x < -0.5) {
		// -1.0,  0.0,  0.0
		tangent  = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	}
	
	else if (gl_Normal.y > 0.5) {
		//  0.0,  1.0,  0.0
		tangent  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
	}
	
	else if (gl_Normal.y < -0.5) {
		//  0.0, -1.0,  0.0
		tangent  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
	}
	
	else if (gl_Normal.z > 0.5) {
		//  0.0,  0.0,  1.0
		tangent  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	}
	
	else if (gl_Normal.z < -0.5) {
		//  0.0,  0.0, -1.0
		tangent  = normalize(gl_NormalMatrix * vec3(-1.0,  0.0,  0.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	}

	color = gl_Color;
}