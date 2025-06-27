#version 120

/*






!! DO NOT REMOVE !! !! DO NOT REMOVE !!

This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !! !! DO NOT REMOVE !!


Sharing and modification rules

Sharing a modified version of my shaders:
-You are not allowed to claim any of the code included in "Chocapic13' shaders" as your own
-You can share a modified version of my shaders if you respect the following title scheme : " -Name of the shaderpack- (Chocapic13' Shaders edit) "
-You cannot use any monetizing links
-The rules of modification and sharing have to be same as the one here (copy paste all these rules in your post), you cannot make your own rules
-I have to be clearly credited
-You cannot use any version older than "Chocapic13' Shaders V4" as a base, however you can modify older versions for personal use
-Common sense : if you want a feature from another shaderpack or want to use a piece of code found on the web, make sure the code is open source. In doubt ask the creator.
-Common sense #2 : share your modification only if you think it adds something really useful to the shaderpack(not only 2-3 constants changed)


Special level of permission; with written permission from Chocapic13, if you think your shaderpack is an huge modification from the original (code wise, the look/performance is not taken in account):
-Allows to use monetizing links
-Allows to create your own sharing rules
-Shaderpack name can be chosen
-Listed on Chocapic13' shaders official thread
-Chocapic13 still have to be clearly credited


Using this shaderpack in a video or a picture:
-You are allowed to use this shaderpack for screenshots and videos if you give the shaderpack name in the description/message
-You are allowed to use this shaderpack in monetized videos if you respect the rule above.


Minecraft website:
-The download link must redirect to the link given in the shaderpack's official thread
-You are not allowed to add any monetizing link to the shaderpack download

If you are not sure about what you are allowed to do or not, PM Chocapic13 on http://www.minecraftforum.net/
Not respecting these rules can and will result in a request of thread/download shutdown to the host/administrator, with or without warning. Intellectual property stealing is punished by law.











*/
#define VIGNETTE
#define VIGNETTE_STRENGTH 1. 
#define VIGNETTE_START 0.15	//distance from the center of the screen where the vignette effect start (0-1)
#define VIGNETTE_END 0.95		//distance from the center of the screen where the vignette effect end (0-1), bigger than VIGNETTE_START

#define GODRAYS
		const float density = 0.1;			
		const float grnoise = 0.9;			//amount of noise

//////////////////////////////END OF ADJUSTABLE VARIABLES
//////////////////////////////END OF ADJUSTABLE VARIABLES
//////////////////////////////END OF ADJUSTABLE VARIABLES

const int maxf = 3;				//number of refinements
const float stp = 0.5;			//size of one step for raytracing algorithm
const float ref = 0.05;			//refinement multiplier
const float inc = 2.4;			//increasement factor at each step
/*--------------------------------*/
varying vec2 texcoord;
varying vec3 lightColor;
varying vec3 avgAmbient;
varying vec3 lightVector;
varying vec3 sunVec;
varying vec3 moonVec;
varying vec3 upVec;
varying vec3 avgAmbient2;
varying vec3 sky1;
varying vec3 sky2;
varying vec3 cloudColor;


varying vec4 lightS;
varying vec2 lightPos;
varying float tr;

varying vec3 sunlight;
varying vec3 ambient_color;
varying vec3 nsunlight;

varying float handItemLight;
varying float eyeAdapt;

varying float SdotU;
varying float MdotU;
varying float sunVisibility;
varying float moonVisibility;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D gcolor;
uniform sampler2D gdepth;
uniform sampler2D gnormal;
uniform sampler2D gaux4;
uniform vec3 skyColor;

uniform sampler2D gaux2;
uniform sampler2D gaux3;
uniform sampler2D noisetex;
const int 		noiseTextureResolution  = 1024;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferPreviousModelView;
uniform ivec2 eyeBrightnessSmooth;
uniform int isEyeInWater;
uniform int worldTime;
uniform float aspectRatio;
uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;
uniform float wetness;
uniform float frameTimeCounter;
uniform int fogMode;

const vec3 moonlight = vec3(0.5, 0.9, 1.4) * 0.005;
const vec3 moonlightS = vec3(0.5, 0.9, 1.4) * 0.001;
float comp = 1.0-near/far/far;			//distance above that are considered as sky
float invRain06 = 1.0-rainStrength*0.6;


/*
vec3 calcFog(vec3 fposition, vec3 color, vec3 fogclr) {
	float density = 1.0/mix(600.0,120,rainStrength);

	float d = length(fposition);


	float fog =  pow(1.0-exp(-d*density),2.2-rainStrength*1.2);

return color*(1.0-fog*(vec3(1.0,0.3,0.1)+rainStrength*vec3(0.0,0.7,0.9))) + fog*length(avgAmbient)*normalize(fogclr)*(1.0-rainStrength*0.85);	
}
*/
float getAirDensity (float h) {
return (max((h),60.0)-40.0)/2;
}
float luma(vec3 color) {
	return dot(color,vec3(0.299, 0.587, 0.114));
}

vec3 calcFog(vec3 fposition, vec3 color, vec3 fogclr,float yPosition,float d) {
	float tmult = mix(min(abs(worldTime-6000.0)/6000.0,1.0),1.0,rainStrength);
	float density = (8000.-tmult*tmult*2000.)*0.75;

	vec3 worldpos = (gbufferModelViewInverse*vec4(fposition,1.0)).rgb+cameraPosition;
	float height = mix(getAirDensity (worldpos.y),0.1,rainStrength*0.8);

	float fog =   clamp(14.0*exp(-getAirDensity (yPosition)/density) * (1.0-exp( -d*height/density ))/height-0.24+rainStrength*0.24,0.0,1.);
	vec3 fogC = fogclr*(0.7+0.3*tmult)*(2.0-rainStrength);
return mix(color,fogC*(1.0-isEyeInWater),fog);	
}

float cdist(vec2 coord) {
	return max(abs(coord.s-0.5),abs(coord.t-0.5))*2.0;
}

vec3 nvec3(vec4 pos) {
    return pos.xyz/pos.w;
}
/*--------------------------------*/
vec4 nvec4(vec3 pos) {
    return vec4(pos.xyz, 1.0);
}

float getnoise(vec2 pos) {
	return fract(sin(dot(pos ,vec2(18.9898f,28.633f))) * 4378.5453f);
}
float invRain07 = 1.0-rainStrength*0.6;


vec3 getSkyColor(vec3 fposition) {
return vec3(0.0);
}

vec4 raytrace(vec3 fragpos, vec3 normal,vec3 fogclr,vec3 rvector) {
    vec4 color = vec4(0.0);
    vec3 start = fragpos;
	
    vec3 vector = stp * rvector;
    fragpos += vector;
    float sr = 0.0;
	float i = 0.0;
	/*--------------------------------*/
    while (i<16.0) {
        vec3 pos = nvec3(gbufferProjection * nvec4(fragpos)) * 0.5 + 0.5;

        if(pos.x < 0.0 || pos.x > 1.0 || pos.y < 0.0 || pos.y > 1.0 || pos.z < 0.0 || pos.z > 1.0) break;
        vec3 spos = vec3(pos.st, texture2D(depthtex1, pos.st).r);
        spos = nvec3(gbufferProjectionInverse * nvec4(spos * 2.0 - 1.0));
        float err = abs(fragpos.z-spos.z);
		if(err < pow(length(vector)*1.5,1.15)){
                sr += 1.0;
                if(sr == maxf){
					bool land = texture2D(depthtex1, pos.st).r < comp;
                    float border = clamp(1.0 - pow(cdist(pos.st), 20.0), 0.0, 1.0);
                    if (isEyeInWater == 0) color = pow(texture2D(gcolor, pos.st),vec4(2.2));
					else color = pow(texture2D(gdepth, pos.st),vec4(2.2));
					vec4 posY = gbufferModelViewInverse*vec4(spos,1.0);
					color.rgb = land ? calcFog(fragpos,color.rgb,fogclr,cameraPosition.y,length(fragpos)) : fogclr*(1.0-isEyeInWater);
					color.a = border;
                    break;
                }
				fragpos -= vector;
                vector *=ref;
				
        
}
else vector *= inc;
fragpos = fragpos + vector;
/*--------------------------------*/
	i += 1.0;
    }
    return color;
}


vec3 Uncharted2Tonemap(vec3 x) {
//tonemapping constants			
float A = 1.3;		
float B = 0.35;		
float C = 0.08;			
	float D = 0.2;		
	float E = 0.02;
	float F = 0.3;
	/*--------------------------------*/
	
	return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
	//return ((x*(A*x+0.025)+0.006)/(x*(A*x+B)+0.09))-0.06666666666;
}
float waterH(vec3 posxz,float time) {

float wave = 0.0;



const float amplitude = 0.2;

vec4 waveXYZW = vec4(posxz.xz,posxz.xz)/vec4(250.,50.,-250.,-150.)+vec4(50.,250.,50.,-250.);
vec2 fpxy = abs(fract(waveXYZW.xy*20.0)-0.5)*2.0;

float d = amplitude*length(fpxy);

wave = cos(waveXYZW.x*waveXYZW.y+time) + 0.5 * cos(2.0*waveXYZW.x*waveXYZW.y+time) + 0.25 * cos(4.0*waveXYZW.x*waveXYZW.y+time);

return d*wave + d*(cos(waveXYZW.z*waveXYZW.w+time) + 0.5 * cos(2.0*waveXYZW.z*waveXYZW.w+time) + 0.25 * cos(4.0*waveXYZW.z*waveXYZW.w+time));

}

float subSurfaceScattering(vec3 vec,vec3 pos, float N) {

return pow(max(dot(vec,normalize(pos)),0.0),N)*(N+1)/6.28;

}
float subSurfaceScattering2(vec3 vec,vec3 pos, float N) {

return pow(max(dot(vec,normalize(pos))*0.5+0.5,0.0),N)*(N+1)/6.28;

}

vec3 drawCloud(vec3 fposition,vec3 color,vec3 vH) {
//const vec4 noiseWeights = 1.0/vec4(1.0,3.5,12.25,42.87)/1.4472;
const float r = 4.0;
const vec3 noiseC = vec3(1.0,r,r*r);
const vec3 noiseWeights = 1.0/vec3(1.0,r,r*r)/dot(1.0/vec3(1.0,r,r*r),vec3(1.0));
/*--------------------------------*/
vec3 sVector = normalize(fposition);
float cosT = max(dot(normalize(sVector),upVec),0.0);
float McosY = MdotU;
float cosY = SdotU;
vec3 tpos = vec3(gbufferModelViewInverse * vec4(sVector,0.0));
vec3 wvec = normalize(tpos);
vec3 wVector = normalize(tpos);
/*--------------------------------*/
float totalcloud = 0.0;
/*--------------------------------*/


vec2 wind = vec2(abs(frameTimeCounter/1000.-0.5),abs(frameTimeCounter/1000.-0.5))+vec2(0.5);
float iMult = 10.0*(0.5+0.4*(3.0-sqrt(cosT)*2.8)*(3.0-sqrt(cosT)*2.8));
float heightA = (400.0+300.0*sqrt(cosT))/(wVector.y);
/*--------------------------------*/	
for (int i = 0;i<7;i++) {
	vec3 intersection = wVector*(heightA-i*iMult); 			//curved cloud plane
	vec2 coord1 = (intersection.xz+abs(3.0-i)*normalize(wind)*3.5)/200000.+wind*0.07;
	vec2 coord = fract(coord1/2.0);
	/*--------------------------------*/
	vec3 noiseSample = vec3(texture2D(noisetex,coord).x,texture2D(noisetex,coord*noiseC.y).x,texture2D(noisetex,coord*noiseC.z).x);

	
	float noise = dot(noiseSample,noiseWeights);
	/*--------------------------------*/
	float cl = noise;
	float d1 = max(1.0-cl*(1.6-rainStrength*0.6),0.); 
	float density = d1*d1*(abs(i-3.0)+1.0)/19.0;  
	/*--------------------------------*/  

	/*--------------------------------*/
	totalcloud += density;

	/*--------------------------------*/
	if (totalcloud > 0.999) break;
}
totalcloud = min(totalcloud,1.0);
return mix(color.rgb,cloudColor,totalcloud*cosT*cosT);

}
//((48*(0.5*48+0.25*0.1)+0.006)/(48*(0.5*48+0.25)+0.3*0.3))-0.02/0.3
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
void main() {




		vec2 deltatexcoord = vec2(lightPos - texcoord);
		deltatexcoord *= density;
		vec2 noisetc = texcoord + deltatexcoord*getnoise(texcoord)*grnoise;
			
			float sample = texture2D(depthtex0, deltatexcoord + noisetc).x;
			float gr = float(sample > comp);
			
			sample = texture2D(depthtex0, 2.0*deltatexcoord + noisetc).x;
			gr += float(sample > comp);
			
			sample = texture2D(depthtex0, 3.0*deltatexcoord + noisetc).x;
			gr += float(sample > comp);
			
			sample = texture2D(depthtex0, 4.0*deltatexcoord + noisetc).x;
			gr += float(sample > comp);
			
			sample = texture2D(depthtex0, 5.0*deltatexcoord + noisetc).x;
			gr += float(sample > comp);
			
			sample = texture2D(depthtex0, 6.0*deltatexcoord + noisetc).x;
			gr += float(sample > comp);
			
			sample = texture2D(depthtex0, 7.0*deltatexcoord + noisetc).x;
			gr += float(sample > comp);
			

gr /= 7.0;


//calculate sun occlusion (only on one pixel) 
if (texcoord.x < 0.002 && texcoord.y < 0.002) {

gr = 0.0;
	for (int i = -6; i < 7;i++) {
		for (int j = -6; j < 7 ;j++) {
		vec2 ij = vec2(i,j);
		float temp = texture2D(depthtex0,lightPos + sign(ij)*sqrt(abs(ij))*vec2(0.002)).x;
		gr += float(temp > comp);
		}
	}
	gr /= 144.0;

}




float Depth = texture2D(depthtex0, texcoord).x;
vec4 albedo = (isEyeInWater == 0)? texture2D(gcolor,texcoord) : texture2D(gdepth,texcoord);
vec3 color = pow(albedo.xyz,vec3(2.2))*0.81;
vec3 normal = texture2D(gnormal,texcoord).xyz;

bool land = Depth < comp;

vec4 fragpos = gbufferProjectionInverse * (vec4(texcoord,Depth,1.0) * 2.0 - 1.0);
fragpos /= fragpos.w;
float skyBoxFactor = moonVisibility*sqrt(max(dot(upVec,normalize(fragpos.xyz))*0.24+0.01,0.0));

float cosT = dot(fragpos.xyz,upVec);
vec3 fogColor = getSkyColor(fragpos.xyz);

bool particle = albedo.a > 0.98999 && albedo.a < 0.99991;
bool transparency = length(normal) > 0.01;

if (!particle && !land) {
	color = fogColor+color*skyBoxFactor;
	if (cosT > 0.0) color.rgb = drawCloud(fragpos.xyz,color.rgb,cameraPosition);
}

	if (transparency) {

		

		normal = normal*2.0-1.0;
		bool iswater = (length(normal) > 0.94 && length(normal) < 0.96);		//material properties are stored into normal length
		bool isice = (length(normal) > 0.96 && length(normal) < 0.98);	
		normal = normalize(normal);
		vec2 newtc = texcoord;
		if (iswater || isice) {
			vec3 wpos = (gbufferModelViewInverse*fragpos).rgb;
			
			vec3 posxz = wpos+cameraPosition;
			float ft = iswater? frameTimeCounter*4.0:0.0;
			
			posxz.x += sin(posxz.z+ft)*0.25;
			posxz.z += cos(posxz.x+ft*0.5)*0.25;
			posxz.xz += sin(posxz.y);
			
			float deltaPos = 0.4;
			float h0 = waterH(posxz,ft);
			float h1 = waterH(posxz - vec3(deltaPos,0.0,0.0),ft);
			float h2 = waterH(posxz - vec3(0.0,0.0,deltaPos),ft);
			
			float dX = ((h0-h1))/deltaPos;
			float dY = ((h0-h2))/deltaPos;

			
			
			vec3 refract = normalize(vec3(dX,dY,1.0));
			float refMult = sqrt(1.0-dot(normal,normalize(fragpos).xyz)*dot(normal,normalize(fragpos).xyz))*0.005;
			
			newtc = texcoord.xy + refract.xy*refMult;
			vec3 mask = texture2D(gnormal,newtc).xyz*2.0-1.0;
			bool watermask = length(mask) > 0.94 && length(mask) < 0.98;
			newtc = watermask? newtc : texcoord;

				
		}
		float Depth2 = texture2D(depthtex1, newtc).x;		
		bool land2 = Depth2 < comp;
		
		
		vec4 uPos = gbufferProjectionInverse * (vec4(newtc,Depth2,1.0) * 2.0 - 1.0);
		uPos /= uPos.w;
		
		vec4 uPosY = gbufferModelViewInverse*vec4(uPos);
		
		vec3 pos2 = uPosY.xyz+vec3(sin(uPosY.z+cameraPosition.z+frameTimeCounter)*0.25,0.0,cos(uPosY.x+cameraPosition.x+frameTimeCounter*0.5)*0.25)+cameraPosition+sin(uPosY.y+cameraPosition.y);
		
		float caustics = waterH((pos2.xyz)*2.0,frameTimeCounter*3.0)*0.2+1.1;
		if ((isEyeInWater == 0 && (iswater || isice)) || (isEyeInWater == 1 && !(iswater || isice))) 				
		color = pow(texture2D(gdepth,newtc).xyz,vec3(2.2))*caustics*caustics*caustics;
			
		else color = pow(texture2D(gcolor,newtc).xyz,vec3(2.2))*0.8;
		
		color = land2? calcFog(uPos.xyz,color,fogColor,uPosY.y+cameraPosition.y,length(fragpos-uPos)) : fogColor+color*skyBoxFactor;
		if (!land2 && cosT > 0.0) color.rgb = drawCloud(fragpos.xyz,color.rgb,cameraPosition);

		
		vec4 rawAlbedo = pow(texture2D(gaux2,texcoord.xy),vec4(2.2,2.2,2.2,1.0));
		rawAlbedo.rgb = rawAlbedo.rgb*0.99+0.01;
		vec4 finalAColor = pow(texture2D(gaux2,texcoord.xy),vec4(2.2,2.2,2.2,1.0));
		color = mix(color,(color*rawAlbedo.rgb)/length(rawAlbedo.rgb),rawAlbedo.a)*(1.0-rawAlbedo.a) + finalAColor.rgb*rawAlbedo.a;
		
		
		float normalDotEye = dot(normal, normalize(fragpos.xyz));
		float fresnel = pow(1.00 + normalDotEye, 5.0)+0.02;		
		
		vec3 reflectedVector = reflect(normalize(fragpos.xyz), normal);
		vec3 sky_c = drawCloud(normalize(reflectedVector),getSkyColor(reflectedVector),cameraPosition);
		

		vec4 reflection = raytrace(fragpos.xyz, normal,sky_c,reflectedVector);
		reflection.rgb = mix(sky_c*(1.0-isEyeInWater), reflection.rgb, reflection.a);		
		
		fresnel *= (iswater || isice)? 1.0 : 0.5;
		color = mix(color,reflection.rgb,fresnel/1.1);

	}

if (land && !particle) color = calcFog(fragpos.xyz,color,fogColor,cameraPosition.y,length(fragpos));
//color = isice? vec3(0.0) : color;

vec3 sunVec = vec3(0.0);
float sunVisibility = 0.0;

if (rainStrength > 0.01){
	vec4 rain = pow(texture2D(gaux4,texcoord),vec4(2.2,2.2,2.2,1.0));
if (length(rain) > 0.001) {	
	vec3 rainRGB = mix(vec3(0.575),normalize(rain.rgb),0.35);
	float rainA = rain.a;
	
	
	vec3 rainC = (pow(max(dot(normalize(fragpos.xyz),sunVec)*0.1+0.9,0.0),6.0)*(0.1+tr*0.9)*pow(sunlight,vec3(0.55))*sunVisibility+pow(max(dot(normalize(fragpos.xyz),-sunVec)*0.05+0.95,0.0),6.0)*10.0*moonlight*moonVisibility)*rainA*0.04 + 0.03*rainA*rainRGB*length(avgAmbient2);
	
	color = mix(color,(color*rainRGB)/length(rainRGB),rainA*0.3)*(1.0-rainA*0.3)+rainC*0.6;
	
	}
	
}



	vec3 curr = Uncharted2Tonemap(color*eyeAdapt*1.85);
	const float div = 0.93145408889;
	color = pow(curr/div,vec3(1.0/2.2));
	//if (color.r > 1.0 || color.g > 1.0 || color.b > 1.0) color.rgb = vec3(1.0,0.0,1.0);


/* DRAWBUFFERS:4 */
	gl_FragData[0] = vec4(color,gr);
}