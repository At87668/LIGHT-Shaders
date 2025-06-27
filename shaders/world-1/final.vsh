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

/*
Disable an effect by putting "//" before "#define" when there is no number after
You can tweak the numbers, the impact on the shaders is self-explained in the variable's name or in a comment
*/

//go to line 46 for changing sunlight color and ambient color line 89 for moon light color
/*--------------------------------*/
varying vec2 texcoord;
varying vec3 lightColor;
varying vec3 avgAmbient;
varying vec3 lightVector;
varying vec3 sunVec;
varying vec3 moonVec;
varying vec3 upVec;

varying vec2 rainPos1;
varying vec2 rainPos2;
varying vec2 rainPos3;
varying vec2 rainPos4;
varying vec4 weights;

varying float fading;

varying vec3 sky1;
varying vec3 sky2;
varying float skyMult;

varying vec4 lightS;
varying vec2 lightPos;

varying vec3 sunlight;
varying vec3 moonlight;
varying vec3 ambient_color;
varying vec3 nsunlight;

varying float handItemLight;
varying float eyeAdapt;


varying float SdotU;
varying float MdotU;
varying float sunVisibility;
varying float moonVisibility;

uniform vec3 skyColor;
uniform vec3 sunPosition;
uniform vec3 upPosition;
uniform int worldTime;
uniform int heldItemId;
uniform int heldBlockLightValue;
uniform float rainStrength;
uniform float wetness;
uniform ivec2 eyeBrightnessSmooth;
uniform float frameTimeCounter;

uniform vec3 cameraPosition;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;
/*--------------------------------*/
////////////////////sunlight color////////////////////
////////////////////sunlight color////////////////////
////////////////////sunlight color////////////////////

const vec3 ToD[7] = vec3[7](  vec3(0.58597,0.16,0.025),
								vec3(0.58597,0.4,0.2),
								vec3(0.58597,0.52344,0.24680),
								vec3(0.58597,0.55422,0.38377),
								vec3(0.58597,0.57954,0.40982),
								vec3(0.58597,0.58597,0.43681),
								vec3(0.58597,0.58597,0.46474));
								
vec3 sky_color = ivec3(60,170,255)/255.0;								
/*--------------------------------*/							
float luma(vec3 color) {
	return dot(color,vec3(0.299, 0.587, 0.114));
}
vec3 getSkyColor(vec3 fposition) {
/*--------------------------------*/
vec3 sVector = normalize(fposition);
/*--------------------------------*/

float cosT = dot(sVector,upVec); 
float mCosT = max(cosT,0.0)+0.03;
float absCosT = 1.0-max(cosT*0.75+0.25,0.08);
float cosS = SdotU;		
float mcosS = max(cosS*0.7+0.3,0.0);		
float cosY = dot(sunVec,sVector);
float Y = acos(cosY);	
/*--------------------------------*/
const float a = -1.;
const float b = -0.32;
const float c = 10.0;
const float d = -3.;
const float e = 0.45;
/*--------------------------------*/
//luminance
float L =  (1.0+a*exp(b/(mCosT)));
float A = 1.0+e*cosY*cosY;
	vec3 sky1 = sky_color;
	vec3 sky2 = mix(sky_color,nsunlight,1.0-mcosS);
	float skyMult = max(SdotU*0.1+0.1,0.0)/0.2;
//gradient
vec3 grad1 = mix(sky1,sky2,absCosT*absCosT);
float sunscat = max(cosY,0.0);
vec3 grad3 = mix(grad1,nsunlight,sunscat*(1.0-mCosT)*sqrt(1.0-max(cosS,0.0))*(1.0-rainStrength*0.5) );

float Y2 = 3.14159265359-Y;	
float L2 = L * (c*exp(d*Y2)+A);

const vec3 moonlight2 = pow(normalize(vec3(0.5, 0.9, 1.4) * 0.03),vec3(3.0))*length(vec3(0.5, 0.9, 1.4) * 0.03);

return grad3*pow(L*(c*exp(d*Y)+A),1.0-rainStrength*0.6)*0.6*skyMult*sunVisibility + mix(vec3(0.5, 0.9, 1.4) * 0.03,moonlight2,1.-L2/2.0)*(L2+1.0)*moonVisibility;
}

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
vec2 noisepattern(vec2 pos) {
	return vec2(abs(fract(sin(dot(pos ,vec2(18.9898f,28.633f))) * 4378.5453f)),abs(fract(sin(dot(pos.yx ,vec2(18.9898f,28.633f))) * 4378.5453f)));
}
void main() {
	vec4 tpos = vec4(sunPosition,1.0)*gbufferProjection;
	tpos = vec4(tpos.xyz/tpos.w,1.0);
	vec2 pos1 = tpos.xy/tpos.z;
	lightPos = pos1*0.5+0.5;


	const vec3 moonlight = vec3(0.5, 0.9, 1.4) * 0.009;
	/*--------------------------------*/
	gl_Position = ftransform();
	texcoord = (gl_MultiTexCoord0).xy;
	/*--------------------------------*/
	if (worldTime < 12700 || worldTime > 23250) {
		lightVector = normalize(sunPosition);
	}
	else {
		lightVector = normalize(-sunPosition);
	}
	/*--------------------------------*/
	sunVec = normalize(sunPosition);
	moonVec = normalize(-sunPosition);
	upVec = normalize(upPosition);
	
	SdotU = dot(sunVec,upVec);
	MdotU = dot(moonVec,upVec);
	sunVisibility = pow(clamp(SdotU+0.15,0.0,0.15)/0.15,4.0);
	moonVisibility = pow(clamp(MdotU+0.15,0.0,0.15)/0.15,4.0);
	/*--------------------------------*/
	
	//reduced the sun color to a 7 array
	float hour = max(mod(worldTime/1000.0+2.0,24.0)-2.0,0.0);  //-0.1
	float cmpH = max(-abs(floor(hour)-6.0)+6.0,0.0); //12
	float cmpH1 = max(-abs(floor(hour)-5.0)+6.0,0.0); //1
	
	
	vec3 temp = ToD[int(cmpH)];
	vec3 temp2 = ToD[int(cmpH1)];
	
	vec3 sunlight = pow(mix(temp,temp2,fract(hour)),vec3(1.0/2.2));



	
	/*--------------------------------*/
	
	//precompute average sky color on each block side to achieve coherence between sky color and ambient color
	vec3 wUp = (gbufferModelView * vec4(vec3(0.0,1.0,0.0),0.0)).rgb;
	vec3 wS1 = (gbufferModelView * vec4(normalize(vec3(3.5,1.0,3.5)),0.0)).rgb;
	vec3 wS2 = (gbufferModelView * vec4(normalize(vec3(-3.5,1.0,3.5)),0.0)).rgb;
	vec3 wS3 = (gbufferModelView * vec4(normalize(vec3(3.5,1.0,-3.5)),0.0)).rgb;
	vec3 wS4 = (gbufferModelView * vec4(normalize(vec3(-3.5,1.0,-3.5)),0.0)).rgb;

	vec3 ambient_Up = (getSkyColor(wUp) + getSkyColor(wS1) + getSkyColor(wS2) + getSkyColor(wS3) + getSkyColor(wS4));

	float eyebright = eyeBrightnessSmooth.y/255.0*0.8+0.2;
	
	ambient_color = pow(normalize(ambient_Up),vec3(1./2.2))*length(ambient_Up);		
	/*--------------------------------*/
	float tr = clamp(min(min(distance(float(worldTime),23250.0),800.0),min(distance(float(worldTime),12700.0),800.0))/800.0-0.5,0.0,1.0)*2.0;

	vec3 sun_ambient = (0.7+length(sunlight)*0.2)*vec3(0.5,0.7,1.0) + sunlight*eyebright*eyebright*eyebright + sunlight *(1.0-tr)*2.0*sunVisibility;
	
	

	vec3 moon_ambient = (moonlight + moonlight*eyebright*eyebright*eyebright);
	
	
	const float pi = 3.14159265359;
		
		
	avgAmbient = (sun_ambient*sunVisibility + moon_ambient*moonVisibility)*eyebright *(0.27+tr*0.65)+0.0002;
	
	
	float truepos = sign(sunPosition.z)*1.0;		//1 -> sun / -1 -> moon
	
	lightColor = mix(sunlight*sunVisibility,12.*moonlight*moonVisibility,(truepos+1.0)/2.);
	if (length(lightColor)>0.0000001)lightColor = mix(lightColor,normalize(vec3(0.25,0.3,0.4))*pow(normalize(lightColor),vec3(0.5))*length(lightColor)*0.5,rainStrength)*0.5;
	
	eyeAdapt = log(clamp(luma(avgAmbient),0.125,48.0))/log(2.0)*0.8;
	eyeAdapt = 1.0/pow(2.0,eyeAdapt)*2.4;
	avgAmbient /= sqrt(3.0);
	/*--------------------------------*/

	handItemLight = 0.0;
	if (heldItemId == 50) {
		// torch
		handItemLight = 0.5;
	}
	
	else if (heldItemId == 76 || heldItemId == 94) {
		// active redstone torch / redstone repeater
		handItemLight = 0.1;
	}
	
	else if (heldItemId == 89) {
		// lightstone
		handItemLight = 0.6;
	}
	
	else if (heldItemId == 10 || heldItemId == 11 || heldItemId == 51) {
		// lava / lava / fire
		handItemLight = 0.5;
	}
	
	else if (heldItemId == 91) {
		// jack-o-lantern
		handItemLight = 0.6;
	}
	
	
	else if (heldItemId == 327) {
		handItemLight = 0.2;
	}
		
float cosS = SdotU;
float mcosS = max(cosS*0.7+0.3,0.0);				
	/*--------------------------------*/
	nsunlight = normalize(pow(mix(sunlight,vec3(0.25,0.3,0.4),rainStrength*0.),vec3(2.2)));
	
	vec3 sky_color = vec3(0.1, 0.35, 1.);
	sky_color = normalize(mix(sky_color,vec3(0.3,0.32,0.4)*length(sunlight),rainStrength)); //normalize colors in order to don't change luminance
	
	sky1 = sky_color;
	sky2 = mix(sky_color,mix(nsunlight,sky_color,rainStrength*0.7),1.0-mcosS);
	skyMult = max(SdotU*0.1+0.1,0.0)/0.2*(1.0-rainStrength*0.6);
	sunlight = pow(sunlight,vec3(2.2));
	
	vec2 centerLight = abs(lightPos*2.0-1.0);
    float distof = min(centerLight.x,centerLight.y);
	fading = clamp(1.0-distof*distof*1.25,0.0,1.0);

	float rainlens = 0.0;
	const float lifetime = 4.0;		//water drop lifetime in seconds
	float ftime = frameTimeCounter*2.0/lifetime;  
	vec2 drop = vec2(0.0,fract(frameTimeCounter/20.0));
	rainPos1 = fract((noisepattern(vec2(-0.94386347*floor(ftime*0.5+0.25),floor(ftime*0.5+0.25))))*0.8+0.1 - drop);
	rainPos2 = fract((noisepattern(vec2(0.9347*floor(ftime*0.5+0.5),-0.2533282*floor(ftime*0.5+0.5))))*0.8+0.1- drop);
	rainPos3 = fract((noisepattern(vec2(0.785282*floor(ftime*0.5+0.75),-0.285282*floor(ftime*0.5+0.75))))*0.8+0.1- drop);
	rainPos4 = fract((noisepattern(vec2(-0.347*floor(ftime*0.5),0.6847*floor(ftime*0.5))))*0.8+0.1- drop);
	weights.x = 1.0-fract((ftime+0.5)*0.5);
	weights.y = 1.0-fract((ftime+1.0)*0.5);
	weights.z = 1.0-fract((ftime+1.5)*0.5);
	weights.w = 1.0-fract(ftime*0.5);
	weights *= rainStrength*clamp((eyeBrightnessSmooth.y-220)/15.0,0.0,1.0);
}
