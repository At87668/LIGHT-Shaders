#version 120

/*
Read my terms of mofification/sharing before changing something below please!
LIGHT Shaders, derived from Chocapic13' shaders,
Chocapic13' shaders, derived from SonicEther v10 rc6.
Place two leading Slashes in front of the following '#define' lines in order to disable an option.
*/

#define SHADOW_MAP_BIAS 0.825

varying vec4 texcoord;

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	
	gl_Position = ftransform();

	float dist = sqrt(gl_Position.x * gl_Position.x + gl_Position.y * gl_Position.y);
	float distortFactor = (1.0f - SHADOW_MAP_BIAS) + dist * SHADOW_MAP_BIAS;
	
	gl_Position.xy *= 1.0f / distortFactor;
	
	texcoord = gl_MultiTexCoord0;

}