#version 120

/*
Read my terms of mofification/sharing before changing something below please!
LIGHT Shaders, derived from Chocapic13' shaders,
Chocapic13' shaders, derived from SonicEther v10 rc6.
Place two leading Slashes in front of the following '#define' lines in order to disable an option.
*/

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