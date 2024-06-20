// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Label"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[Space(15)]_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		_BumpMap("Normal", 2D) = "bump" {}
		_NormalPower("Normal Power", Range( 0 , 1)) = 0
		_MetallicRSmoothnessA("Metallic (R) Smoothness (A)", 2D) = "black" {}
		_MetallicPower1("Metallic Power", Range( 0 , 1)) = 0
		_SmoothnessPower1("Smoothness Power", Range( 0 , 1)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+2" }
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
		uniform float _NormalPower;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _MetallicRSmoothnessA;
		SamplerState sampler_MetallicRSmoothnessA;
		uniform float4 _MetallicRSmoothnessA_ST;
		uniform float _MetallicPower1;
		uniform float _SmoothnessPower1;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			o.Normal = UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap ), _NormalPower );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			o.Albedo = ( _Color * tex2DNode1 ).rgb;
			float2 uv_MetallicRSmoothnessA = i.uv_texcoord * _MetallicRSmoothnessA_ST.xy + _MetallicRSmoothnessA_ST.zw;
			float4 tex2DNode3 = tex2D( _MetallicRSmoothnessA, uv_MetallicRSmoothnessA );
			o.Metallic = ( tex2DNode3.r * _MetallicPower1 );
			o.Smoothness = ( tex2DNode3.a * _SmoothnessPower1 );
			o.Alpha = 1;
			clip( tex2DNode1.a - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18703
774;73;753;557;1251.487;756.2434;1.87463;True;False
Node;AmplifyShaderEditor.SamplerNode;1;-512,-256;Inherit;True;Property;_MainTex;Albedo;2;0;Create;False;0;0;False;0;False;-1;None;2c9f2180dcc5b47468e338c23e5f9a89;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;7;-512,496;Inherit;False;Property;_SmoothnessPower1;Smoothness Power;7;0;Create;True;0;0;False;0;False;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-512,368;Inherit;False;Property;_MetallicPower1;Metallic Power;6;0;Create;True;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-804.9041,2.713055;Inherit;False;Property;_NormalPower;Normal Power;4;0;Create;True;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-512,128;Inherit;True;Property;_MetallicRSmoothnessA;Metallic (R) Smoothness (A);5;0;Create;True;0;0;False;0;False;-1;None;20a0d2c88a9662d49a0e938c77b160e9;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;4;-428,-432;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;False;1;Space(15);False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-176,-352;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-125.858,482.0298;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-127.1573,329.9301;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-512,-64;Inherit;True;Property;_BumpMap;Normal;3;0;Create;False;0;0;False;0;False;-1;None;d0a08e790c559cd4a9a812498f657aa1;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;160,-80;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Custom/Label;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;2;True;TransparentCutout;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;3;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;4;0
WireConnection;5;1;1;0
WireConnection;8;0;3;4
WireConnection;8;1;7;0
WireConnection;9;0;3;1
WireConnection;9;1;6;0
WireConnection;2;5;10;0
WireConnection;0;0;5;0
WireConnection;0;1;2;0
WireConnection;0;3;9;0
WireConnection;0;4;8;0
WireConnection;0;10;1;4
ASEEND*/
//CHKSM=27132545789C1F62D41ED8E1A7FCFBCF2F2685CB