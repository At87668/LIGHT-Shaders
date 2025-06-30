#version 120

/*
!! DO NOT REMOVE !!
Original code is from Chocapic13' shaders and this code is modified by LIGHT Shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec4 color;
varying vec3 fragpos;
varying vec3 sunVec;
varying vec3 moonVec;
varying vec3 upVec;


varying vec3 sky1;
varying vec3 sky2;

varying vec3 nsunlight;

varying float SdotU;
varying float MdotU;
varying float sunVisibility;
varying float moonVisibility;
varying float skyMult;

varying vec4 texcoord;
varying vec4 lmcoord;

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

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {

/* DRAWBUFFERS:7 */
	vec4 tex = texture2D(texture, texcoord.xy)*color;
	tex.a = tex.a;
	gl_FragData[0] = tex;
}