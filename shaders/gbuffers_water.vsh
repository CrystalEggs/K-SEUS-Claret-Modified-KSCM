#version 120

#define WAVING_WATER
#define Water_WaveSpeed1	0.25		//[0.01 0.025 0.035 0.05 0.1 0.25 0.35 0.45 0.55 0.65 0.75 0.85 0.95 1.0] //This Controls the first part of the waving water speed, lower numbers means slower waving and Higher makes it faster
#define Water_WaveSpeed2	0.60		//[0.01 0.025 0.035 0.05 0.1 0.25 0.35 0.45 0.55 0.60 0.65 0.75 0.85 0.95 1.0] //This Controls the Second part of the waving water speed, lower numbers means slower waving and Higher makes it faster

uniform int worldTime;

uniform vec3 cameraPosition;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;
varying vec3 worldPosition;
varying vec4 vertexPos;

varying vec3 normal;
varying vec3 globalNormal;
varying vec3 tangent;
varying vec3 binormal;
varying vec3 viewVector;
varying vec3 viewVector2;
varying float distance;

attribute vec4 mc_Entity;

varying float iswater;
varying float isice;
varying float isStainedGlass;


varying vec3 wpos;
uniform float frameTimeCounter;
uniform float rainStrength;


const float PI = 3.1415927;


void main() {

	iswater = 0.0f;
	isice = 0.0f;
	isStainedGlass = 0.0f;

	
	if (mc_Entity.x == 79) {
		isice = 1.0f;
	}
	
		 vertexPos = gl_Vertex;

	if (mc_Entity.x == 1971.0f)
	{
		iswater = 1.0f;
	}
	
	if (mc_Entity.x == 8 || mc_Entity.x == 9) {
		iswater = 1.0f;
	}

	if (mc_Entity.x == 95 || mc_Entity.x == 160)
	{
		isStainedGlass = 1.0f;
	}
	
	//waving water	
	vec4 positions = gl_ModelViewMatrix * gl_Vertex;
	float displacement = 0.0;
	
	vec4 viewposition = gbufferModelViewInverse * positions;
	vec3 worldpos = viewposition.xyz + cameraPosition;
	wpos = worldpos;
	
	if(mc_Entity.x == 8.0 || mc_Entity.x == 9.0) {
		iswater = 1.0;
		float fy = fract(worldpos.y + 0.001);
		
#ifdef WAVING_WATER
		float wave = 0.05 * sin(2 * PI * (frameTimeCounter * Water_WaveSpeed1 - worldpos.x /  7.0 - worldpos.z / 13.0))
				   + 0.05 * sin(2 * PI * (frameTimeCounter * Water_WaveSpeed2 - worldpos.x / 11.0 - worldpos.z /  5.0));
		displacement = clamp(wave, -fy, 1.0-fy);
	
	#ifdef Dynamic_Water
	float Dynamic_wavingWater = 2.0f;
	#else
	float Dynamic_wavingWater = 1.0f;
	#endif
	
#ifdef Dynamic_Weather
	#ifdef Dynamic_Water
		float next_moon_phase = moonPhase + 1;

		if(float(moonPhase) == 7) {
			next_moon_phase = 0;
		}

		float moon_phase_smooth = mix(moonPhase, next_moon_phase, float(worldTime) / 24000.0);

		if(rainStrength < 0.99) {
			Dynamic_wavingWater *= ((abs(float(moon_phase_smooth) - 3) + 1) / 5) + 0.5;
		}
		//displacement += mix(0.028f, 0.060f, displacement * moonPhase * 5.40f);
	#endif
#endif
		
		viewposition.y += displacement * 1.0 * Dynamic_wavingWater;
		//viewposition.y += mix(0.028f, 0.060f, displacement * moonPhase * 1.40f);
		viewposition.y += displacement * 1.8 * rainStrength;

#endif
	}	

	
	vec4 viewPos = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
	vec4 position = viewPos;
	
	
//waving water
	viewposition = gbufferModelView * viewposition;

	worldPosition.xyz = viewPos.xyz + cameraPosition.xyz;

	vec4 localPosition = gl_ModelViewMatrix * gl_Vertex;

	distance = length(localPosition.xyz);

	gl_Position = gl_ProjectionMatrix * (gbufferModelView * position);
//waving water
	gl_Position += gl_ProjectionMatrix * viewposition;


	color = gl_Color;

	texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;

	lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;



	gl_FogFragCoord = gl_Position.z;


	
	
	normal = normalize(gl_NormalMatrix * gl_Normal);
	globalNormal = normalize(gl_Normal);

	if (gl_Normal.x > 0.5) {
		//  1.0,  0.0,  0.0
		tangent  = normalize(gl_NormalMatrix * vec3( 0.0,  0.0, -1.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	} else if (gl_Normal.x < -0.5) {
		// -1.0,  0.0,  0.0
		tangent  = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	} else if (gl_Normal.y > 0.5) {
		//  0.0,  1.0,  0.0
		tangent  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
	} else if (gl_Normal.y < -0.5) {
		//  0.0, -1.0,  0.0
		tangent  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
	} else if (gl_Normal.z > 0.5) {
		//  0.0,  0.0,  1.0
		tangent  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	} else if (gl_Normal.z < -0.5) {
		//  0.0,  0.0, -1.0
		tangent  = normalize(gl_NormalMatrix * vec3(-1.0,  0.0,  0.0));
		binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	}
	
	mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
                          tangent.y, binormal.y, normal.y,
                          tangent.z, binormal.z, normal.z);

	viewVector = (gl_ModelViewMatrix * gl_Vertex).xyz;
	viewVector2 = normalize(viewVector);
	viewVector = normalize(tbnMatrix * viewVector);


	
}