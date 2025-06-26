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
#define VIGNETTE_START 0.35	//distance from the center of the screen where the vignette effect start (0-1)
#define VIGNETTE_END 0.75		//distance from the center of the screen where the vignette effect end (0-1), bigger than VIGNETTE_START

	//#define GODRAYS			//in this step previous godrays result is blurred
		const float exposure = 2.2;			//godrays intensity
		const float density = 1.0;			
		const float grnoise = 0.0;		//amount of noise 


//////////////////////////////END OF ADJUSTABLE VARIABLES
//////////////////////////////END OF ADJUSTABLE VARIABLES
//////////////////////////////END OF ADJUSTABLE VARIABLES

const int maxf = 4;				//number of refinements
const float stp = 1.0;			//size of one step for raytracing algorithm
const float ref = 0.03;			//refinement multiplier
const float inc = 2.1;			//increasement factor at each step
/*--------------------------------*/
varying vec2 texcoord;

varying vec3 avgAmbient;
varying vec3 sunVec;
varying vec3 moonVec;
varying vec3 upVec;
varying vec3 lightColor;

varying vec3 sky1;
varying vec3 sky2;
varying float skyMult;
varying vec3 nsunlight;

varying float fading;

varying vec2 lightPos;

varying vec3 sunlight;
const vec3 moonlight = vec3(0.5, 0.9, 1.4) * 0.005;
const vec3 moonlightS = vec3(0.5, 0.9, 1.4) * 0.001;
varying vec3 ambient_color;


varying float handItemLight;
varying float eyeAdapt;
varying float SdotU;
varying float MdotU;
varying float sunVisibility;
varying float moonVisibility;

uniform sampler2D gcolor;
uniform sampler2D gaux1;

varying vec2 rainPos1;
varying vec2 rainPos2;
varying vec2 rainPos3;
varying vec2 rainPos4;
varying vec4 weights;

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

	float distratio(vec2 pos, vec2 pos2) {
	
		return distance(pos*vec2(aspectRatio,1.0),pos2*vec2(aspectRatio,1.0));
	}
									

	
	float yDistAxis (in float degrees) {
		vec4 dVector = vec4(lightPos,texcoord);
		float ydistAxis = dot(dVector,vec4(-degrees,1.0,degrees,-1.0));
		return abs(ydistAxis);
		
	}
	
	float smoothCircleDist (in float lensDist) {

	vec2 lP = (lightPos*lensDist)-0.5*lensDist+0.5;
			 
	return distratio(lP, texcoord);
		
	}
	
	float cirlceDist (float lensDist, float size) {
	vec2 lP = (lightPos*lensDist)-(0.5*lensDist-0.5);
		return pow(min(distratio(lP, texcoord),size)/size,10.);
	}
	

	
	
vec3 Uncharted2Tonemap(vec3 x) {
//tonemapping constants			
float A = 0.4;		
float B = 0.2;		
float C = 0.1;			
	float D = 0.3;		
	float E = 0.02;
	float F = 0.3;
	/*--------------------------------*/
	return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

float gen_circular_lens(vec2 center, float size) {
	float dist=distratio(center,texcoord.xy)/size;
	return exp(-dist*dist);
}



float smStep (float edge0,float edge1,float x) {
float t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
return t * t * (3.0 - 2.0 * t); }
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	const float pi = 3.14159265359;
	float rainlens = 0.0;
	const float lifetime = 4.0;		//water drop lifetime in seconds
	/*--------------------------------*/
	float ftime = frameTimeCounter*2.0/lifetime;  
	vec2 drop = vec2(0.0,fract(frameTimeCounter/20.0));
	/*--------------------------------*/

		if (rainStrength > 0.02) {
		/*--------------------------------*/

		rainlens += gen_circular_lens(rainPos1,0.1)*weights.x;
		/*--------------------------------*/


		rainlens += gen_circular_lens(rainPos2,0.07)*weights.y;
		/*--------------------------------*/


		rainlens += gen_circular_lens(rainPos3,0.086)*weights.z;
		/*--------------------------------*/


		rainlens += gen_circular_lens(rainPos4,0.092)*weights.w;
		/*--------------------------------*/

	}

	vec2 fake_refract = vec2(sin(frameTimeCounter + texcoord.x*100.0 + texcoord.y*50.0),cos(frameTimeCounter + texcoord.y*100.0 + texcoord.x*50.0)) ;
	vec2 newTC = clamp(texcoord + fake_refract * 0.01 * (rainlens+isEyeInWater*0.2),1.0/vec2(viewWidth,viewHeight),1.0-1.0/vec2(viewWidth,viewHeight));
	vec3 c = texture2D(gaux1,newTC).xyz; 

	
	float gr = 0.0;
	
	vec2 aspectVec = (newTC-lightPos)*vec2(aspectRatio,1.0);
	float illuminationDecay = pow(max(1.0-length(aspectVec)/sqrt(3.0),0.0),3.0);
	if (illuminationDecay > 0.001) {

	const float blurScale = 0.002;

	float distFix = clamp(distance(newTC,lightPos)*100.-0.5,0.0,1.0);
	vec2 deltaTextCoord = normalize(newTC - lightPos)*blurScale*distFix;
	vec2 textCoord = newTC - deltaTextCoord*4.0;
			
			gr += texture2D(gaux1, textCoord + deltaTextCoord).a;
			gr += texture2D(gaux1, textCoord + 2.0 * deltaTextCoord).a;
			gr += texture2D(gaux1, textCoord + 3.0 * deltaTextCoord).a;
			gr += texture2D(gaux1, textCoord + 4.0 * deltaTextCoord).a;
			gr += texture2D(gaux1, textCoord + 5.0 * deltaTextCoord).a;
			gr += texture2D(gaux1, textCoord + 6.0 * deltaTextCoord).a;
			gr += texture2D(gaux1, textCoord + 7.0 * deltaTextCoord).a;
	vec3 grC = min(lightColor*exposure*(gr)*illuminationDecay * (1.0-isEyeInWater),9.0);
	c = ((1.0-(1.0-c)*(1.0-grC/7.0)));
}
	
	
	


c = ((1.0-(1.0-c)*(1.0-rainlens*avgAmbient*0.17)));
	
	

if (fading > 0.01) {
    float sunvisibility = texture2D(gaux1,vec2(0.0015)).a * fading;
	
	const float lensBrightness = 5.0;
	vec3 lC = lightColor*sunvisibility*(1.0-rainStrength*0.9);



	// End of Dirty Lens
	
	// Anamorphic Lens
	if (sunvisibility > 0.01) {
		
			float visibility = exp(-smoothCircleDist(1.0)*3.0);
			const vec3 lensCol = 0.3 * lensBrightness * vec3(0.2, 0.8, 2.55);			
			float anamorphic_lens = exp(-yDistAxis(0.0)*yDistAxis(0.0)*500.0);
			vec3 lens = anamorphic_lens * lensCol * length(lC) * visibility;
	
	



		
			// Sunrays
			const float sunrayBrightness = 1.1 * lensBrightness ;
			visibility = exp(-smoothCircleDist(1.0)*16.0);
			vec4 sunray = exp(-vec4(yDistAxis(1.5), yDistAxis(-1.3),yDistAxis(5.0),yDistAxis(-4.8))*25.0);
			float sunrays = dot(sunray,vec4(sunrayBrightness * visibility))*(1.0-rainStrength*0.8);
			lens += sunrays*lC;
	
	
			// Circle Lens 1
			const vec3 circleLens1Col = vec3(2.52, 1.2, 0.4) * 0.1 * lensBrightness;
			vec3 circleLens1 = exp(-vec3(cirlceDist(-0.15, 0.07),cirlceDist(-0.2, 0.07),cirlceDist(-0.25, 0.07))*15.0);
			float lensFlare = circleLens1.x * circleLens1.y * circleLens1.z;		
			lens +=  lensFlare * circleLens1Col*lC;
		
		
		
		
			// Circle Lens 2
			const vec3 circleLens2Col = 0.07 * lensBrightness * vec3(1.6, 2.55, 0.4);
			vec3 circleLens2 = exp(-vec3(cirlceDist(-0.4, 0.13),cirlceDist(-0.5, 0.13),cirlceDist(-0.6, 0.13))*15.0);			
			lensFlare = circleLens2.x * circleLens2.y * circleLens2.z;			
			lens += circleLens2Col * lensFlare*lC;
		
		
		
			// Circle Lens 3	
			const vec3 circleLens3Col = vec3(0.4, 2.55, 1.55) * 0.05 * lensBrightness;
			vec3 circleLens3 = exp(-vec3(cirlceDist(-0.75, 0.09),cirlceDist(-0.8, 0.09),cirlceDist(-0.85, 0.09))*15.0);	
			lensFlare = circleLens3.x*circleLens3.y*circleLens3.z;			
			lens +=  circleLens3Col * lensFlare*lC;
		

		// Ring Lens 		
			const vec3 ringLensCol = 0.3 * lensBrightness * vec3(0.2, 0.8, 2.55);
			
			vec2 ringLens =  vec2(exp(-cirlceDist(-0.7, 0.5)*15.0),exp(-cirlceDist(-0.9, 0.5)*15.0));
			
			lensFlare = max(ringLens.y - ringLens.x, 0.0);
			lens +=  ringLensCol * lensFlare * lensFlare * length(lC);
			lens = min(lens,1.0);
			c = ((1.0-(1.0-c)*(1.0-lens)));		
		}
	
	
}
	
	
	
	


		


	#ifdef VIGNETTE
	float len = length(newTC.xy-vec2(.5));
	float len2 = distratio(newTC.xy,vec2(.5));
	/*--------------------------------*/
	float dc = mix(len,len2,0.3);
    float vignette = smStep(VIGNETTE_END, VIGNETTE_START,  dc);
	/*--------------------------------*/
	
	c = c*(0.8+vignette*1.2)*0.5;
	#endif	

	gl_FragColor = vec4(c,1.);
}