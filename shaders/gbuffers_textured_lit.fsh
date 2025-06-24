#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

	const int shadowMapResolution = 1024;		//shadowmap resolution
	const float shadowDistance = 120.0;		//draw distance of shadows
	const bool 	shadowHardwareFiltering0 = true;
	const float	sunPathRotation	= -40.0f;
/*
const int gcolorFormat = RGBA16;
const int gdepthFormat = RGBA8;
const int gnormalFormat = RGBA16;		//normals are exported only for reflective surfaces
*/
#define SHADOW_MAP_BIAS 0.825
varying vec4 color;

varying vec2 texcoord;
varying vec4 ambientNdotL;
varying vec4 sunlightMat;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;



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


	if (diffuse > 0.00001){
		
		vec4 worldposition = gbufferModelViewInverse * fragposition;
		

		worldposition = shadowModelView * worldposition;
		worldposition = shadowProjection * worldposition;
		worldposition /= worldposition.w;
		float distb = length(worldposition.st);
		float distortFactor = mix(1.0,distb,SHADOW_MAP_BIAS);
		worldposition.xy /= distortFactor; 

		
		if (max(abs(worldposition.x),abs(worldposition.y)) < 0.99) {
			float diffthresh = sunlightMat.a > 0.9? 0.0015 : distortFactor*distortFactor*(0.006*tan(acos(diffuse)) + 0.0006);
			const float halfres = (0.25/shadowMapResolution);
			float offset = ((rainStrength*2.0)*halfres+halfres);
			
			worldposition = worldposition * 0.5f + vec4(0.5,0.5,0.5-diffthresh,0.5);
			

			diffuse = dot(vec4(shadow2D(shadow,vec3(worldposition.st + vec2(offset,offset), worldposition.z)).x,shadow2D(shadow,vec3(worldposition.st + vec2(-offset,offset), worldposition.z)).x,shadow2D(shadow,vec3(worldposition.st + vec2(offset,-offset), worldposition.z)).x,shadow2D(shadow,vec3(worldposition.st + vec2(-offset,-offset), worldposition.z)).x),vec4(0.25*diffuse));
	}
	}


	vec3 sunlight = sunlight*diffuse;
	
	
	albedo.rgb = pow(albedo.rgb,vec3(2.2));
	
	
	vec3 fColor = (sunlight + ambientNdotL.rgb)*albedo.rgb;
	fColor = pow(fColor,vec3(1./2.2));


/* DRAWBUFFERS:01 */
	albedo.a = (albedo.a > 0.98999 && albedo.a < 0.99991)? 0.99992 : albedo.a;
	gl_FragData[0] = vec4(fColor,albedo.a);
	gl_FragData[1] = vec4(pow(ambientNdotL.rgb*albedo.rgb,vec3(1.0/2.2)),albedo.a);
}