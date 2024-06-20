// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Standard (Masked color)"
{
	Properties
	{
		[Header(Main)][Space(10)]_Color("Color", Color) = (1,1,1,0)
		_MainTex("Albedo", 2D) = "white" {}
		[Space(10)][Header(Normal)][Space(10)]_BumpMap("Normal", 2D) = "bump" {}
		_BumpScale("Normal Power", Range( 0 , 1)) = 1
		[Space(10)][Header(Metallic  Smoothness)][Space(10)]_MetallicGlossMap("Metallic (R) Smoothness (A)", 2D) = "white" {}
		_Glossiness("Smoothness Power", Range( 0 , 1)) = 1
		_Metallic("Metallic Power", Range( 0 , 1)) = 1
		[Space(10)][Header(Occlusion)][Space(10)]_OcclusionMap("Occlusion", 2D) = "white" {}
		_OcclusionStrength("Occlusion Power", Range( 0 , 1)) = 0.5
		[HDR][Space(10)][Header(Emissive)][Space(10)]_EmissiveColor("Color", Color) = (0,0,0,0)
		_OcclusionMap1("Emissive", 2D) = "white" {}
		[Space(10)][Header(Masked Color)][Space(10)]_ColorMask("Color", Color) = (1,1,1,0)
		_Mask("Mask", 2D) = "white" {}
		_BumpScale1("Mask Faloff", Range( 0.001 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform float _BumpScale;
		uniform float4 _ColorMask;
		uniform float4 _Color;
		uniform sampler2D _Mask;
		SamplerState sampler_Mask;
		uniform float4 _Mask_ST;
		uniform float _BumpScale1;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _EmissiveColor;
		uniform sampler2D _OcclusionMap1;
		uniform float4 _OcclusionMap1_ST;
		uniform sampler2D _MetallicGlossMap;
		SamplerState sampler_MetallicGlossMap;
		uniform float4 _MetallicGlossMap_ST;
		uniform float _Metallic;
		uniform float _Glossiness;
		uniform sampler2D _OcclusionMap;
		SamplerState sampler_OcclusionMap;
		uniform float4 _OcclusionMap_ST;
		uniform float _OcclusionStrength;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			o.Normal = UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap ), _BumpScale );
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float4 lerpResult21 = lerp( _ColorMask , _Color , ( 1.0 - pow( tex2D( _Mask, uv_Mask ).r , _BumpScale1 ) ));
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			o.Albedo = ( lerpResult21 * tex2D( _MainTex, uv_MainTex ) ).rgb;
			float2 uv_OcclusionMap1 = i.uv_texcoord * _OcclusionMap1_ST.xy + _OcclusionMap1_ST.zw;
			o.Emission = ( _EmissiveColor * tex2D( _OcclusionMap1, uv_OcclusionMap1 ) ).rgb;
			float2 uv_MetallicGlossMap = i.uv_texcoord * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
			float4 tex2DNode8 = tex2D( _MetallicGlossMap, uv_MetallicGlossMap );
			o.Metallic = ( tex2DNode8.r * _Metallic );
			o.Smoothness = ( tex2DNode8.a * _Glossiness );
			float2 uv_OcclusionMap = i.uv_texcoord * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
			o.Occlusion = pow( tex2D( _OcclusionMap, uv_OcclusionMap ).r , _OcclusionStrength );
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18703
322;290;989;597;1515.891;-717.9722;1.761772;True;False
Node;AmplifyShaderEditor.SamplerNode;11;-912.8998,-123.5001;Inherit;True;Property;_Mask;Mask;12;0;Create;True;0;0;False;1;;False;-1;None;8239f42a2471d0242957676998d19c9f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-904.6917,88.80737;Inherit;False;Property;_BumpScale1;Mask Faloff;13;0;Create;False;0;0;False;0;False;1;0.26;0.001;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;24;-483.6917,55.80737;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;12;-816,-768;Inherit;False;Property;_ColorMask;Color;11;0;Create;False;0;0;False;3;Space(10);Header(Masked Color);Space(10);False;1,1,1,0;1,0.7062074,0.2784314,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;22;-486.6443,-48.56833;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;9;-816,-576;Inherit;False;Property;_Color;Color;0;0;Create;False;0;0;False;2;Header(Main);Space(10);False;1,1,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-912,-368;Inherit;True;Property;_MainTex;Albedo;1;0;Create;False;0;0;False;0;False;-1;None;1a0577e2e1485e741896b450a62d4103;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;20;-544,1040;Inherit;False;Property;_OcclusionStrength;Occlusion Power;8;0;Create;False;0;0;False;0;False;0.5;0.412;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-912,896;Inherit;True;Property;_OcclusionMap;Occlusion;7;0;Create;False;0;0;False;3;Space(10);Header(Occlusion);Space(10);False;-1;None;e99580dbc173d59479658c5a0afd59b3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;18;-544,576;Inherit;False;Property;_Metallic;Metallic Power;6;0;Create;False;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;21;-400,-688;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;27;-800,1184;Inherit;False;Property;_EmissiveColor;Color;9;1;[HDR];Create;False;0;0;False;3;Space(10);Header(Emissive);Space(10);False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;-1209.216,318.5922;Inherit;False;Property;_BumpScale;Normal Power;3;0;Create;False;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-912,512;Inherit;True;Property;_MetallicGlossMap;Metallic (R) Smoothness (A);4;0;Create;False;0;0;False;3;Space(10);Header(Metallic  Smoothness);Space(10);False;-1;None;4fceb0aa9ea8adc458b5bafdde57be20;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;26;-888.1126,1408;Inherit;True;Property;_OcclusionMap1;Emissive;10;0;Create;False;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;-544,704;Inherit;False;Property;_Glossiness;Smoothness Power;5;0;Create;False;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-128,1312;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-240,640;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-240,512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-112,-386.5996;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;7;-912,256;Inherit;True;Property;_BumpMap;Normal;2;0;Create;False;0;0;False;3;Space(10);Header(Normal);Space(10);False;-1;None;fae6c4244793e0f49b87ef1bb013d295;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;23;-256,944;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;48,264.8638;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Standard (Masked color);False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;24;0;11;1
WireConnection;24;1;25;0
WireConnection;22;0;24;0
WireConnection;21;0;12;0
WireConnection;21;1;9;0
WireConnection;21;2;22;0
WireConnection;28;0;27;0
WireConnection;28;1;26;0
WireConnection;15;0;8;4
WireConnection;15;1;17;0
WireConnection;16;0;8;1
WireConnection;16;1;18;0
WireConnection;10;0;21;0
WireConnection;10;1;5;0
WireConnection;7;5;14;0
WireConnection;23;0;6;1
WireConnection;23;1;20;0
WireConnection;0;0;10;0
WireConnection;0;1;7;0
WireConnection;0;2;28;0
WireConnection;0;3;16;0
WireConnection;0;4;15;0
WireConnection;0;5;23;0
ASEEND*/
//CHKSM=AFD89C0411087CFEFF9A3FABCBD694CD6CE7F07B