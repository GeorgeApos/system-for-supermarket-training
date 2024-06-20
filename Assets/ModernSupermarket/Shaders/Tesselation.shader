// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Standard (Tesselation)"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.12
		_Tiling("Tiling", Float) = 1
		[Space(10)][Header(Main)][Space(10)]_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		[Space(10)][Header(Normal)][Space(10)]_BumpMap("Normal", 2D) = "bump" {}
		_BumpScale("Normal Power", Range( 0 , 1)) = 1
		[Space(10)][Header(Metallic Smoothness)][Space(10)]_MetallicGlossMap("Metallic (R) Smoothness (A)", 2D) = "white" {}
		_Metallic("Metallic Power", Range( 0 , 1)) = 1
		_GlossMapScale("Smoothness Power", Range( 0 , 1)) = 1
		[Space(10)][Header(Occlusion)][Space(10)]_OcclusionMap("Occlusion", 2D) = "white" {}
		_GlossMapScale1("Occlusion Power", Range( 0 , 1)) = 1
		[Space(10)][Header(Parallax Tesselation Displacement)][Space(10)]_ParallaxMap("Heightmap", 2D) = "white" {}
		_ParallaxPower("Parallax Power", Range( 0 , 1)) = 0
		_ParallaxBias("Parallax Bias", Range( 0 , 1)) = 1
		_TesselationPower("Tesselation Power", Range( 0.01 , 16)) = 0.01
		_DisplacementPower("Displacement Power", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#include "Tessellation.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float _DisplacementPower;
		uniform sampler2D _ParallaxMap;
		uniform float4 _ParallaxMap_ST;
		uniform sampler2D _BumpMap;
		uniform float _Tiling;
		uniform float _ParallaxPower;
		uniform float _ParallaxBias;
		uniform float _BumpScale;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform sampler2D _MetallicGlossMap;
		SamplerState sampler_MetallicGlossMap;
		uniform float _Metallic;
		uniform float _GlossMapScale;
		uniform sampler2D _OcclusionMap;
		SamplerState sampler_OcclusionMap;
		uniform float _GlossMapScale1;
		uniform float _TesselationPower;
		uniform float _Cutoff = 0.12;


		inline float2 POM( sampler2D heightMap, float2 uvs, float2 dx, float2 dy, float3 normalWorld, float3 viewWorld, float3 viewDirTan, int minSamples, int maxSamples, float parallax, float refPlane, float2 tilling, float2 curv, int index )
		{
			float3 result = 0;
			int stepIndex = 0;
			int numSteps = ( int )lerp( (float)maxSamples, (float)minSamples, saturate( dot( normalWorld, viewWorld ) ) );
			float layerHeight = 1.0 / numSteps;
			float2 plane = parallax * ( viewDirTan.xy / viewDirTan.z );
			uvs.xy += refPlane * plane;
			float2 deltaTex = -plane * layerHeight;
			float2 prevTexOffset = 0;
			float prevRayZ = 1.0f;
			float prevHeight = 0.0f;
			float2 currTexOffset = deltaTex;
			float currRayZ = 1.0f - layerHeight;
			float currHeight = 0.0f;
			float intersection = 0;
			float2 finalTexOffset = 0;
			while ( stepIndex < numSteps + 1 )
			{
			 	currHeight = tex2Dgrad( heightMap, uvs + currTexOffset, dx, dy ).r;
			 	if ( currHeight > currRayZ )
			 	{
			 	 	stepIndex = numSteps + 1;
			 	}
			 	else
			 	{
			 	 	stepIndex++;
			 	 	prevTexOffset = currTexOffset;
			 	 	prevRayZ = currRayZ;
			 	 	prevHeight = currHeight;
			 	 	currTexOffset += deltaTex;
			 	 	currRayZ -= layerHeight;
			 	}
			}
			int sectionSteps = 2;
			int sectionIndex = 0;
			float newZ = 0;
			float newHeight = 0;
			while ( sectionIndex < sectionSteps )
			{
			 	intersection = ( prevHeight - prevRayZ ) / ( prevHeight - currHeight + currRayZ - prevRayZ );
			 	finalTexOffset = prevTexOffset + intersection * deltaTex;
			 	newZ = prevRayZ - intersection * layerHeight;
			 	newHeight = tex2Dgrad( heightMap, uvs + finalTexOffset, dx, dy ).r;
			 	if ( newHeight > newZ )
			 	{
			 	 	currTexOffset = finalTexOffset;
			 	 	currHeight = newHeight;
			 	 	currRayZ = newZ;
			 	 	deltaTex = intersection * deltaTex;
			 	 	layerHeight = intersection * layerHeight;
			 	}
			 	else
			 	{
			 	 	prevTexOffset = finalTexOffset;
			 	 	prevHeight = newHeight;
			 	 	prevRayZ = newZ;
			 	 	deltaTex = ( 1 - intersection ) * deltaTex;
			 	 	layerHeight = ( 1 - intersection ) * layerHeight;
			 	}
			 	sectionIndex++;
			}
			return uvs.xy + finalTexOffset;
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, 1.0,5.0,_TesselationPower);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float4 _Vector3 = float4(0,1,0,0.1);
			float2 uv_ParallaxMap = v.texcoord * _ParallaxMap_ST.xy + _ParallaxMap_ST.zw;
			float3 linearToGamma31 = LinearToGammaSpace( tex2Dlod( _ParallaxMap, float4( uv_ParallaxMap, 0, 0.0) ).rgb );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( ( (_Vector3.z + (_DisplacementPower - _Vector3.x) * (_Vector3.w - _Vector3.z) / (_Vector3.y - _Vector3.x)) * linearToGamma31 ) * ase_vertexNormal );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (_Tiling).xx;
			float2 uv_TexCoord16 = i.uv_texcoord * temp_cast_0;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 ase_tanViewDir = mul( ase_worldToTangent, ase_worldViewDir );
			float2 OffsetPOM15 = POM( _ParallaxMap, uv_TexCoord16, ddx(uv_TexCoord16), ddy(uv_TexCoord16), ase_worldNormal, ase_worldViewDir, ase_tanViewDir, 8, 8, _ParallaxPower, _ParallaxBias, _ParallaxMap_ST.xy, float2(0,0), 0 );
			float2 ParallaxUV20 = OffsetPOM15;
			o.Normal = UnpackScaleNormal( tex2D( _BumpMap, ParallaxUV20 ), _BumpScale );
			float4 tex2DNode1 = tex2D( _MainTex, ParallaxUV20 );
			o.Albedo = ( _Color * tex2DNode1 ).rgb;
			float4 tex2DNode3 = tex2D( _MetallicGlossMap, ParallaxUV20 );
			o.Metallic = ( tex2DNode3.r * _Metallic );
			o.Smoothness = ( tex2DNode3.a * _GlossMapScale );
			o.Occlusion = ( tex2D( _OcclusionMap, ParallaxUV20 ).a + _GlossMapScale1 );
			o.Alpha = 1;
			clip( tex2DNode1.a - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18703
691;73;836;557;2315.088;-420.2166;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;19;-2000.521,500.7431;Inherit;False;Property;_Tiling;Tiling;1;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-1817.67,481.5294;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;6;-2013.041,666.8859;Inherit;True;Property;_ParallaxMap;Heightmap;11;0;Create;False;0;0;False;3;Space(10);Header(Parallax Tesselation Displacement);Space(10);False;None;d3cf5ca067ede3c4185010437ab37c53;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;18;-1591.877,796.0205;Inherit;False;Property;_ParallaxBias;Parallax Bias;13;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1593.67,689.5291;Inherit;False;Property;_ParallaxPower;Parallax Power;12;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;15;-1289.67,481.5294;Inherit;False;0;8;False;-1;16;False;-1;2;0.02;0;False;1,1;False;0,0;7;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT2;0,0;False;6;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;24;-1493.409,1103.357;Float;False;Constant;_Vector3;Vector 3;33;0;Create;True;0;0;False;0;False;0,1,0,0.1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-1578.89,1017.42;Float;False;Property;_DisplacementPower;Displacement Power;15;0;Create;True;0;0;False;0;False;0;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-1049.669,481.5294;Inherit;False;ParallaxUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;28;-1579.248,1302.863;Inherit;True;Property;_TextureSample0;Texture Sample 0;12;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;26;-1268.409,1104.357;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-1294.234,-242.1841;Inherit;False;20;ParallaxUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LinearToGammaNode;31;-1260.792,1294.338;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1408,-448;Inherit;False;Property;_BumpScale;Normal Power;5;0;Create;False;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-992,384;Inherit;False;Property;_GlossMapScale1;Occlusion Power;10;0;Create;False;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1024,176;Inherit;True;Property;_OcclusionMap;Occlusion;9;0;Create;False;0;0;False;3;Space(10);Header(Occlusion);Space(10);False;-1;None;9bfd4dbc683d9bb46af8a0f0c7517d8a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;12;-1007.498,-45.24272;Inherit;False;Property;_Metallic;Metallic Power;7;0;Create;False;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-948.1996,968.3351;Float;False;Property;_TesselationPower;Tesselation Power;14;0;Create;True;0;0;False;0;False;0.01;16;0.01;16;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-1024,-256;Inherit;True;Property;_MetallicGlossMap;Metallic (R) Smoothness (A);6;0;Create;False;0;0;False;3;Space(10);Header(Metallic Smoothness);Space(10);False;-1;None;3d92cc4b91eed474b99166214f4668f9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;22;-1010.709,1321.425;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-1024,-768;Inherit;True;Property;_MainTex;Albedo;3;0;Create;False;0;0;False;0;False;-1;None;1f1cf1e97be112a44b3d530d3f4f54d8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-886.1491,1189.639;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;8;-1024,-1024;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;False;3;Space(10);Header(Main);Space(10);False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;-1007.498,82.75728;Inherit;False;Property;_GlossMapScale;Smoothness Power;8;0;Create;False;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-719.4984,50.7573;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1024,-512;Inherit;True;Property;_BumpMap;Normal;4;0;Create;False;0;0;False;3;Space(10);Header(Normal);Space(10);False;-1;None;c23fe3eada7453f439bdd4aa42f947e9;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-719.4984,-45.24272;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-688,320;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-640,-896;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceBasedTessNode;33;-613.8511,968.8156;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;5;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-731.5141,1187.707;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Standard (Tesselation);False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.12;True;True;0;True;TransparentCutout;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;16;0;19;0
WireConnection;15;0;16;0
WireConnection;15;1;6;0
WireConnection;15;2;17;0
WireConnection;15;4;18;0
WireConnection;20;0;15;0
WireConnection;28;0;6;0
WireConnection;26;0;25;0
WireConnection;26;1;24;1
WireConnection;26;2;24;2
WireConnection;26;3;24;3
WireConnection;26;4;24;4
WireConnection;31;0;28;0
WireConnection;4;1;21;0
WireConnection;3;1;21;0
WireConnection;1;1;21;0
WireConnection;27;0;26;0
WireConnection;27;1;31;0
WireConnection;14;0;3;4
WireConnection;14;1;13;0
WireConnection;2;1;21;0
WireConnection;2;5;7;0
WireConnection;11;0;3;1
WireConnection;11;1;12;0
WireConnection;35;0;4;4
WireConnection;35;1;34;0
WireConnection;10;0;8;0
WireConnection;10;1;1;0
WireConnection;33;0;29;0
WireConnection;23;0;27;0
WireConnection;23;1;22;0
WireConnection;0;0;10;0
WireConnection;0;1;2;0
WireConnection;0;3;11;0
WireConnection;0;4;14;0
WireConnection;0;5;35;0
WireConnection;0;10;1;4
WireConnection;0;11;23;0
WireConnection;0;14;33;0
ASEEND*/
//CHKSM=07C67F5FC7455A20BC4727B85ABEE81DDDCCFC6F