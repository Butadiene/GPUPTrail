/// The MIT License
// Copyright © 2019 Butadiene
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



Shader "Butadienetrail/GpuPtrailmemory"
{
	Properties
	{
		_taTex ("inputtexemroy", 2D) = "white" {}
		
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Overlay" }
		LOD 100
			
		Cull Off
        ZWrite Off
        ZTest Always
		Pass
		{
		
			
			 Name "Update"

			CGPROGRAM
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment frag
			
			sampler2D _taTex;
			#include "UnityCustomRenderTexture.cginc"
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			
			float3 pack(float3 xyz, uint ix) {
					uint3 xyzI = asuint(xyz);
					xyzI = (xyzI >> (ix * 8)) % 256;
					return (float3(xyzI) + 0.5) / 255.0;
			}

			float3 unpack(float2 uv) {
				float texWidth = _CustomRenderTextureWidth;
				float3 e = float3(1.0/texWidth/2, 3.0/texWidth/2, 0);
				uint3 v0 = uint3(tex2Dlod(_SelfTexture2D, float4(uv - e.yz,0,0)).xyz * 255.) << 0;
				uint3 v1 = uint3(tex2Dlod(_SelfTexture2D, float4(uv - e.xz,0,0)).xyz * 255.) << 8;
				uint3 v2 = uint3(tex2Dlod(_SelfTexture2D, float4(uv + e.xz,0,0)).xyz * 255.) << 16;
				uint3 v3 = uint3(tex2Dlod(_SelfTexture2D, float4(uv + e.yz,0,0)).xyz * 255.) << 24;
				uint3 v = v0 + v1 + v2 + v3;
				return asfloat(v);
			}

			float rand(float2 co){
				return frac(sin(dot(co.xy, float2(12.9898,78.233))) * 43758.5453);
			}

			float3 unpacks(float2 uv) {
				float texWidth = 4;
				float3 e = float3(1.0/texWidth/2, 3.0/texWidth/2, 0);
				uint3 v0 = uint3(tex2Dlod(_taTex, float4(uv - e.yz,0,0)).xyz * 255.) << 0;
				uint3 v1 = uint3(tex2Dlod(_taTex, float4(uv - e.xz,0,0)).xyz * 255.) << 8;
				uint3 v2 = uint3(tex2Dlod(_taTex, float4(uv + e.xz,0,0)).xyz * 255.) << 16;
				uint3 v3 = uint3(tex2Dlod(_taTex, float4(uv + e.yz,0,0)).xyz * 255.) << 24;
				uint3 v = v0 + v1 + v2 + v3;
				return asfloat(v);
			}


			float3 atract(float3 par, float3 pos1f, float3 pos2f, float3 pos3f, float2 intuv)//usetrail
			{
				float gravity = par.z;
				float velocity = par.y;
				float4 v = normalize(float4(pos1f - pos2f, 0.1));
				float3 patract = unpacks(float2(0.5, 0.75)) - pos1f + 0.1*par.x*float3(rand(intuv.yy + 1) - 0.5, rand(intuv.yy + 2) - 0.5, rand(intuv.yy) - 0.5);
				float4 attract = normalize(float4(patract, 0.1));
				float3 parpos = pos1f + 0.004*velocity*float3(v.xyz*(1 - gravity) + attract.xyz*gravity)*unity_DeltaTime.x * 90;
				return parpos;
			}
			fixed4 frag (v2f_customrendertexture i) : SV_Target
			{
			
			//unpack
				
				float2 uv = i.globalTexcoord;

				float texWidth = _CustomRenderTextureWidth;
				float texhigh =  _CustomRenderTextureHeight;

				float2 intuv =uv;

				float intx =intuv.x*texWidth-frac(intuv.x*texWidth);
				intuv.x=(intx-fmod(intx,4)+2)/texWidth;
				
				float inty =intuv.y*texhigh-frac(intuv.y*texhigh);
				intuv.y=(inty-fmod(inty,4)+2)/texhigh;
				
				float xmod = fmod(intx,4);
				float ymod = fmod(inty,4);

				float4 col = 0;
			
			if(intuv.x>(3/texWidth))
			{
				
				float3 pos1f = unpack(intuv-float2(4/texWidth,0));
				col =float4( pack(pos1f,xmod),1);
				
			}
			else 
			{
				float3 par  = unpacks(float2(0.5,0.25));
				float3 pos2f = unpack(intuv + float2(4 / texWidth, 0));
				float3 pos3f = unpack(intuv + float2(8 / texWidth, 0));
				float3 pos1f = unpack(intuv);
				float3 paratr = atract(par, pos1f, pos2f, pos3f, intuv);
				col =float4( pack(paratr,xmod),1);
			}
				return col;
			}
			ENDCG
		}
	}
}
