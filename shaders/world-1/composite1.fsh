#version 120

/*
!! DO NOT REMOVE !! !! DO NOT REMOVE !!

Original code is from Chocapic13' shaders and this code is modified by LIGHT Shaders
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
-You are allowed to use this shaderpack for monetized videos if you respect the rule above.

Minecraft website:
-The download link must redirect to the link given in the shaderpack's official thread
-You are not allowed to add any monetizing link to the shaderpack download

If you are not sure about what you are allowed to do or not, PM Chocapic13 on http://www.minecraftforum.net/
Not respecting these rules can and will result in a request of thread/download shutdown to the host/administrator, with or without warning, intellectual property stealing is punished by law.

*/

// TAA Resolve Pass
// Blends the current frame with the previous frame's history stored in
// colortex3 (which is never cleared, so it survives between frames).
// Reading and writing the history in the same pass is safe: OptiFine/Iris
// flip the buffer, so the read always returns the previous frame's result.

#define TAA

varying vec2 texcoord;

uniform sampler2D gaux1;     // colortex4: current frame color (alpha = godrays occlusion factor)
uniform sampler2D colortex3; // TAA history buffer (previous frame)

uniform sampler2D depthtex0;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 gbufferPreviousModelView;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

uniform float viewWidth;
uniform float viewHeight;
uniform float near;
uniform float far;

// The history buffer must persist between frames.
// (const buffer settings have to be declared in a program, not in shaders.properties)
const bool colortex3Clear = false;

#ifdef TAA
// Reproject the current pixel back to its screen position in the previous frame.
vec2 Reprojection(vec3 screenPos) {
	vec3 ndcPos = screenPos * 2.0 - 1.0;

	vec4 viewPos = gbufferProjectionInverse * vec4(ndcPos, 1.0);
	viewPos /= viewPos.w;

	// Move the world position by the camera delta so static geometry
	// reprojections land on the same world point.
	vec4 playerPos = gbufferModelViewInverse * viewPos;
	playerPos.xyz += cameraPosition - previousCameraPosition;

	vec4 previousPos = gbufferPreviousModelView * playerPos;
	previousPos = gbufferPreviousProjection * previousPos;

	return previousPos.xy / previousPos.w * 0.5 + 0.5;
}
#endif

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	vec4 current = texture2D(gaux1, texcoord);
	vec3 color = current.rgb;

#ifdef TAA
	float depth = texture2D(depthtex0, texcoord).r;
	// Depth above this value is considered sky (same threshold as composite).
	float skyDepth = 1.0 - near / far / far;

	// Only apply temporal blending to world geometry:
	// - Sky pixels (sun, moon, stars, clouds) have no meaningful depth for
	//   reprojection; blending them makes the sun disc flicker away.
	// - Close pixels (< 0.56) are the hand and the vanilla sun/moon quads
	//   (rendered at depth 0.5), which must stay untouched by TAA.
	if (depth > 0.56 && depth < skyDepth) {
		vec2 previousCoord = Reprojection(vec3(texcoord, depth));

		// Only sample history that falls inside the screen.
		if (clamp(previousCoord, 0.0, 1.0) == previousCoord) {
			vec3 history = texture2D(colortex3, previousCoord).rgb;

			// First frame after (re)loading the pack has no valid history.
			if (length(history) > 0.001) {
				// Neighborhood of the current frame color.
				vec2 texel = 1.0 / vec2(viewWidth, viewHeight);
				vec3 near0 = texture2D(gaux1, texcoord + vec2(-texel.x, 0.0)).rgb;
				vec3 near1 = texture2D(gaux1, texcoord + vec2( texel.x, 0.0)).rgb;
				vec3 near2 = texture2D(gaux1, texcoord + vec2(0.0, -texel.y)).rgb;
				vec3 near3 = texture2D(gaux1, texcoord + vec2(0.0,  texel.y)).rgb;

				vec3 minColor = min(color, min(min(near0, near1), min(near2, near3)));
				vec3 maxColor = max(color, max(max(near0, near1), max(near2, near3)));

				// Clip the history into the neighborhood sphere to prevent ghosting.
				vec3 clipCenter = (minColor + maxColor) * 0.5;
				float clipRadius = length(maxColor - clipCenter);

				vec3 historyVector = history - clipCenter;
				float historyDistance = length(historyVector);
				if (historyDistance > clipRadius) {
					historyVector *= clipRadius / historyDistance;
				}
				history = clipCenter + historyVector;

				// Blend more aggressively on smooth areas, less on edges.
				vec3 edgeColor = color * 4.0 - near0 - near1 - near2 - near3;
				float edge = clamp(length(edgeColor) * 0.5773502691896258, 0.0, 1.0);

				color = mix(color, history, 0.8 + edge * 0.19);
			}
		}
	}
#endif

	/* DRAWBUFFERS:43 */
	// colortex4: resolved color, alpha (godrays factor) is passed through untouched.
	// colortex3: store the resolved color as the next frame's history.
	gl_FragData[0] = vec4(color, current.a);
	gl_FragData[1] = vec4(color, 1.0);
}
