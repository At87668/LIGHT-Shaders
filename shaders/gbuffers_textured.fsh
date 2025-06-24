#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/
	const float shadowMapResolution = 1024.0;		//shadowmap resolution


varying vec4 color;
varying vec2 texcoord;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

varying vec4 ambientNdotL;
varying vec4 sunlightMat;

uniform sampler2D texture;
uniform sampler2DShadow shadow;

uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 upPosition;
uniform int fogMode;
uniform int worldTime;
uniform float wetness;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;
uniform int heldBlockLightValue;

#define SHADOW_MAP_BIAS 0.825

vec3 sunlight = sunlightMat.rgb;
float diffuse = ambientNdotL.a;
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	vec4 albedo = texture2D(texture, texcoord)*color;


	vec2 adjustedTexCoord = texcoord;
	
	
	vec4 fragposition = gbufferProjectionInverse*(vec4(gl_FragCoord.xy/vec2(viewWidth,viewHeight),gl_FragCoord.z,1.0)*2.0-1.0);
	fragposition /= fragposition.w;
	
	float mfp = clamp(length(fragposition.xyz),2.4,16.0);		
	float handLight = (1.0/mfp/mfp-1.0/16.0/16.0)*heldBlockLightValue*heldBlockLightValue/256.0;

	vec4 worldposition = gbufferModelViewInverse * vec4(fragposition);
	
	worldposition = shadowModelView * worldposition;
	worldposition = shadowProjection * worldposition;
	worldposition /= worldposition.w;
	float distb = length(worldposition.st);
	float distortFactor = mix(1.0,distb,SHADOW_MAP_BIAS);
	worldposition.xy /= distortFactor; 

	
	float diffthresh = 0.0005*distortFactor*distortFactor;
	const float halfres = (0.5/shadowMapResolution);
	float offset = (rainStrength*2.0)*halfres+halfres;
	
	worldposition = worldposition * 0.5f + vec4(0.5,0.5,0.5-diffthresh,0.5);
	
	if (max(abs(worldposition.x-0.5),abs(worldposition.y-0.5)) < 0.48) {
	diffuse = dot(vec4(shadow2D(shadow,vec3(worldposition.st + vec2(offset,offset), worldposition.z)).x,shadow2D(shadow,vec3(worldposition.st + vec2(-offset,offset), worldposition.z)).x,shadow2D(shadow,vec3(worldposition.st + vec2(offset,-offset), worldposition.z)).x,shadow2D(shadow,vec3(worldposition.st + vec2(-offset,-offset), worldposition.z)).x),vec4(0.2));
	}
	


	vec3 sunlight = sunlight*diffuse;
	
	vec3 ambient = ambientNdotL.rgb;
	
	albedo.rgb = pow(albedo.rgb,vec3(2.2));
	
	
	vec3 fColor = (sunlight+ambient+handLight*vec3(1.0,0.45,0.09)*0.5)*albedo.rgb;
	
	fColor = pow(fColor,vec3(1./2.2));


/* DRAWBUFFERS:01 */


	gl_FragData[0] = vec4(fColor*(albedo.a*0.5+0.5),step(0.1,albedo.a)*0.99);
	gl_FragData[1] = vec4(pow((ambientNdotL.rgb+handLight*vec3(1.0,0.45,0.09)*0.5)*albedo.rgb,vec3(1.0/2.2))*(albedo.a*0.5+0.5),step(0.1,albedo.a)*0.99);

}