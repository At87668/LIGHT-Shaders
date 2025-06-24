#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec4 color;

varying vec3 moonVec;
varying vec3 upVec;
varying vec2 texcoord;

varying float moonVisibility;



uniform vec3 sunPosition;
uniform vec3 upPosition;
uniform int worldTime;
uniform int heldItemId;
uniform int heldBlockLightValue;
uniform float rainStrength;
uniform float wetness;
uniform ivec2 eyeBrightnessSmooth;

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

	moonVec = normalize(-sunPosition);
	upVec = normalize(upPosition);

	float MdotU = dot(moonVec,upVec);

	moonVisibility = pow(clamp(MdotU+0.15,0.0,0.15)/0.15,3.0);
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;



	color = gl_Color;
	
	gl_Position = ftransform();
	gl_Position.z = 0.0;
}

