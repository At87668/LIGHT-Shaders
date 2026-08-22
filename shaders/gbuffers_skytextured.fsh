#version 120

/*
!! DO NOT REMOVE !!
Original code is from Chocapic13' shaders and this code is modified by LIGHT Shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

/* DRAWBUFFERS:0 */

// Keep the vanilla square sun and moon shapes but wrap them in a soft glow.
// Comment out (or toggle off in the shader options screen) to hide the sun disc.
#define SQUARE_SUN_MOON

varying vec4 color;

varying vec3 moonVec;
varying vec3 upVec;
varying vec2 texcoord;

varying float moonVisibility;
varying float sunVisibility;


uniform sampler2D texture;
uniform vec3 sunPosition;
uniform vec3 upPosition;
uniform int worldTime;
uniform int heldItemId;
uniform int heldBlockLightValue;
uniform float rainStrength;
uniform float wetness;
uniform ivec2 eyeBrightnessSmooth;
uniform float viewWidth;
uniform float viewHeight;

uniform vec3 cameraPosition;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

const int FOGMODE_LINEAR = 9729;
const int FOGMODE_EXP = 2048;

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {

	vec4 texColor = texture2D(texture, texcoord.xy) * color;

	// The sun texture is warm-toned (red > blue) while the moon texture is cool-toned.
	bool isSun = texColor.r > texColor.b;

#ifdef SQUARE_SUN_MOON
	// Keep the vanilla square shape but boost the brightness into HDR range so the
	// bloom / godrays passes pick the body up and wrap it in a soft glow.
	float visibility = isSun ? sunVisibility : moonVisibility;
	float glowBoost = 1.0 + visibility * 4.0;
	texColor.rgb = pow(texColor.rgb, vec3(2.2)) * glowBoost * texColor.a;
#else
	// Option disabled: hide the sun disc entirely (legacy behaviour) and keep the
	// moon at its original brightness.
	if (isSun) discard;
#endif

	gl_FragData[0] = texColor;

}