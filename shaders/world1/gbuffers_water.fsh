#version 120

/*
!! DO NOT REMOVE !!
Original code is from Chocapic13' shaders and this code is modified by LIGHT Shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/
	const float smres = 1024.0;
	
	#define MIX_TEX	0.7	
	vec4 watercolor = vec4(0.1,0.4,0.6,0.4); 	//water color and opacity (r,g,b,opacity)

varying vec4 color;
varying vec4 lmtexcoord;
varying vec3 sunlight;
varying vec3 binormal;
varying vec3 normal;
varying vec3 tangent;
varying float iswater;

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
uniform vec3 cameraPosition;
uniform vec3 upPosition;
uniform int fogMode;
uniform int worldTime;
uniform float wetness;
uniform float rainStrength;
uniform float frameTimeCounter;
uniform float viewWidth;
uniform float viewHeight;
uniform int heldBlockLightValue;

#define SHADOW_MAP_BIAS 0.825

vec2 texcoord = lmtexcoord.xy;
vec2 lmcoord = lmtexcoord.zw;



float subSurfaceScattering(vec3 pos, float N) {

return pow(max(dot(normalize(sunPosition),normalize(pos)),0.0),30.0)*9.8676064717;

}
float waterH(vec3 posxz,float time) {

float wave = 0.0;



const float amplitude = 0.2;

vec4 waveXYZW = vec4(posxz.xz,posxz.xz)/vec4(250.,50.,-250.,-150.)+vec4(50.,250.,50.,-250.);
vec2 fpxy = abs(fract(waveXYZW.xy*20.0)-0.5)*2.0;

float d = -amplitude*length(fpxy);

wave = cos(waveXYZW.x*waveXYZW.y+time) + 0.5 * cos(2.0*waveXYZW.x*waveXYZW.y+time) + 0.25 * cos(4.0*waveXYZW.x*waveXYZW.y+time);

return d*wave + d*(cos(waveXYZW.z*waveXYZW.w+time) + 0.5 * cos(2.0*waveXYZW.z*waveXYZW.w+time) + 0.25 * cos(4.0*waveXYZW.z*waveXYZW.w+time));

}


float skyL = lmcoord.t*1.032258 - 0.0322580625;

	float modlmap = 16.0-lmcoord.s*15.7; 
	float torch_lightmap = max(0.75/(modlmap*modlmap)-0.00315,0.0);

	const vec3 moonlight = vec3(0.5, 0.9, 1.4) * 0.004;

vec3 sunVec = normalize(sunPosition);
vec3 upVec = normalize(upPosition);


vec2 visibility = vec2(dot(sunVec,upVec),dot(-sunVec,upVec));

float NdotL = dot(normal,normalize(sunPosition));
float NdotU = dot(normal,upVec);

vec2 trCalc = min(abs(float(worldTime)-vec2(23250.0,12700.0)),800.);
float tr = max(min(trCalc.x,trCalc.y)/400.0-1.0,0.0);



//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
void main() {

visibility = pow(clamp(visibility+0.15,0.0,0.15)/0.15,vec2(4.0));
	//vec2 bounced = vec4(NdotL*-0.08+0.16,NdotL*0.16+0.33)*pow(skyL,3.0);

	float skyL = max(lmcoord.t-2./16.0,0.0)*1.14285714286;		
	
		
	float SkyL2 = skyL*skyL;
	float skyc2 = mix(1.0,SkyL2,skyL);
	
		
	vec4 bounced = vec4(NdotL,NdotL,NdotL,NdotU) * vec4(-0.05*skyL*skyL,0.32,0.7,0.18) + vec4(0.5,0.66,0.7,0.3);
	bounced *= vec4(skyc2,skyc2,visibility.x-tr*visibility.x,0.8);



	vec3 sun_ambient = bounced.w * (vec3(0.16,0.5,1.5)-rainStrength*vec3(0.0,0.3,1.27)) + sunlight*(sqrt(bounced.w)*bounced.x*3. + bounced.z);
	vec3 moon_ambient = (moonlight + moonlight*bounced.y)*(1.0-rainStrength*0.5);




	






vec4 albedo = texture2D(texture, texcoord)*color;
vec3 colorrgb = pow(albedo.rgb,vec3(2.2));
if (iswater > 0.9) colorrgb = mix(albedo.rgb,vec3(0.35,0.67,0.72),0.8)*0.4;

vec3 lightColor = mix(sunlight,moonlight*(1.0-rainStrength*0.6),visibility.y)*tr;


	if (worldTime > 12700 && worldTime < 23250) NdotL = -NdotL;

	

	
	vec4 fragposition = gbufferProjectionInverse*(vec4(gl_FragCoord.xy/vec2(viewWidth,viewHeight),gl_FragCoord.z,1.0)*2.0-1.0);
	fragposition /= fragposition.w;
	
	float mfp = clamp(length(fragposition.xyz),2.4,16.0);		
	float handLight = (1.0/mfp/mfp-1.0/16.0/16.0)*heldBlockLightValue*heldBlockLightValue/256.0;
	
	vec4 worldposition = gbufferModelViewInverse * fragposition;
	vec3 wpos = worldposition.xyz;
	worldposition = shadowModelView * worldposition;
	worldposition = shadowProjection * worldposition;
	worldposition /= worldposition.w;
	float distb = length(worldposition.st);
	float distortFactor = mix(1.0,distb,SHADOW_MAP_BIAS);
	worldposition.xy /= distortFactor; 
	
	float diffthresh = distortFactor*distortFactor*(0.0012*tan(acos(NdotL)) + 0.0012)*10.;
	worldposition = worldposition * 0.5f + vec4(0.5,0.5,0.5-diffthresh,0.5);
	
	vec2 centervec = abs(clamp(worldposition.xy-0.5,-0.5,0.5));
	float centerSquareDist = max(centervec.x,centervec.y);
	const float halfres = (0.5/smres);
	float offset = ((rainStrength*2.0)*halfres+halfres);
	

	float shadows = 1.0;
	if ( centerSquareDist < 0.49 && NdotL > 0.) {
	shadows = dot(vec4(shadow2D(shadow,vec3(worldposition.st + vec2(offset,offset), worldposition.z)).x,shadow2D(shadow,vec3(worldposition.st + vec2(-offset,offset), worldposition.z)).x,shadow2D(shadow,vec3(worldposition.st + vec2(offset,-offset), worldposition.z)).x,shadow2D(shadow,vec3(worldposition.st + vec2(-offset,-offset), worldposition.z)).x),vec4(0.25));
	//shadows = shadow2D(shadow,vec3(worldposition.st, worldposition.z-diffthresh)).x;
	}
	
	vec4 frag2;
	frag2 = vec4((normal) * 0.5f + 0.5f, 1.0f);		
	
	
	vec3 posxz = wpos+cameraPosition;
	float ft = frameTimeCounter*max(iswater*8.0-4.0,0.0);
	posxz.x += sin(posxz.z+ft)*0.25;
	posxz.z += cos(posxz.x+ft*0.5)*0.25;
	posxz.xz += sin(posxz.y);
	
	float deltaPos = 0.4;
	float h0 = waterH(posxz,ft);
	float h1 = waterH(posxz - vec3(deltaPos,0.0,0.0),ft);
	float h2 = waterH(posxz - vec3(0.0,0.0,deltaPos),ft);
	
	float dX = (h0-h1)/deltaPos;
	float dY = (h0-h2)/deltaPos;

	vec3 bump = normalize(vec3(dX,dY,1.0));
			
		
		float bumpmult = 0.055*(iswater+0.0);	
		
		bump = bump * vec3(bumpmult) + vec3(0.0f, 0.0f, 1.0f - bumpmult);
		mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
							tangent.y, binormal.y, normal.y,
							tangent.z, binormal.z, normal.z);
		
		frag2 = vec4(normalize(bump * tbnMatrix)*(0.5-iswater*0.025) + 0.5, 1.0);
	
	
	
	vec3 sunlightL = lightColor*shadows*0.9;
	vec3 ambientNdotL = (sun_ambient*visibility.x + moon_ambient*visibility.y)*SkyL2*(0.03+tr*0.17)*0.8 + vec3(1.0,0.45,0.09)*torch_lightmap*0.75 + vec3(0.0012,0.0012,0.0012)*min(skyL+6/16.,9/16.);
	
	vec3 fColor = (sunlightL*max(NdotL,0.0)+ambientNdotL+handLight*vec3(1.0,0.45,0.09)*0.5)*colorrgb;
	


	
	fColor = pow(fColor,vec3(1.0/2.2));
	

/* DRAWBUFFERS:526 */

	gl_FragData[0] = vec4(fColor,mix(albedo.a,0.4,max(iswater*2.0-1.0,0.0)));
	gl_FragData[1] = frag2;
	gl_FragData[2] = vec4(pow(colorrgb,vec3(1./2.2)),mix(albedo.a,0.4,max(iswater*2.0-1.0,0.0)));
}
