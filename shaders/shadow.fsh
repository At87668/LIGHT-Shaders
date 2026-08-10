#version 120

/*
Read my terms of mofification/sharing before changing something below please!
LIGHT Shaders, derived from Chocapic13' shaders,
Chocapic13' shaders, derived from SonicEther v10 rc6.
Place two leading Slashes in front of the following '#define' lines in order to disable an option.
*/

#define SHADOW_QUALITY 1 //[0 1 2 3]
#if SHADOW_QUALITY == 0
	const int shadowMapResolution = 512;
#elif SHADOW_QUALITY == 1
	const int shadowMapResolution = 1024;
#elif SHADOW_QUALITY == 2
	const int shadowMapResolution = 2048;
#elif SHADOW_QUALITY == 3
	const int shadowMapResolution = 4096;
#endif
const float shadowDistance = 120.0; //[60.0 80.0 100.0 120.0 140.0 160.0 180.0 200.0 240.0 280.0 320.0]

varying vec4 texcoord;

uniform sampler2D tex;

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	vec4 col = texture2D(tex, texcoord.xy);

	if (col.a < 0.001) discard;
	
	gl_FragColor = col;

	gl_FragData[0] = texture2D(tex,texcoord.xy);
}