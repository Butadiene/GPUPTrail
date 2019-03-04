// The MIT License
// Copyright © 2019 Butadiene
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Shader "Butadienetrail/GpuPtrailrender"
{
	Properties
	{
		_RTex("Memory texture ",2D)="black"{}
		_offset("offset",float)=1
		_texwidth("Texwidth",float)=1024
		_texhight("Texhight",float)=1024
		_long("longpixel",float)=1
		_scale("scale",float)=1
	
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		LOD 100

		Cull off
		Blend SrcAlpha One
		ZWrite Off
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			 uniform float _offset;
			 uniform float _texhight;
			 uniform float _texwidth;
			 uniform float _long;
			 uniform float _scale;
			 sampler2D _RTex;
			
			
			 float rand(float2 co) 
			 {
				return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
			 }

			 float3 unpack(float2 uv) {
				float texWidth = _texwidth;
				float3 e = float3(1.0/texWidth/2, 3.0/texWidth/2, 0);
				uint3 v0 = uint3(tex2Dlod(_RTex, float4(uv - e.yz,0,0)).xyz * 255.) << 0;
				uint3 v1 = uint3(tex2Dlod(_RTex, float4(uv - e.xz,0,0)).xyz * 255.) << 8;
				uint3 v2 = uint3(tex2Dlod(_RTex, float4(uv + e.xz,0,0)).xyz * 255.) << 16;
				uint3 v3 = uint3(tex2Dlod(_RTex, float4(uv + e.yz,0,0)).xyz * 255.) << 24;
				uint3 v = v0 + v1 + v2 + v3;
				return asfloat(v);
			}
			struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				float4 uv3 : TEXCOORD3;
			};

			struct v2g
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				float4 uv3 : TEXCOORD3;
			};
			struct g2f
			{
				
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				float4 uv3 : TEXCOORD3;
			};
			struct fout
			{
				float4 pixel: SV_Target;
				float depth : SV_Depth;
			};
			
			
			

			v2g vert (appdata v)
			{
				v2g o;
				o.pos =v.vertex;
				o.uv = v.uv;
				o.uv1 = v.uv1;
				o.uv2 = v.uv2;
				o.uv3 = v.uv3;
				return o;
			}
			[maxvertexcount(12)]
			void geom (triangle v2g input[3],inout TriangleStream<g2f> outStream)
			{
				
				float3 viewp = _WorldSpaceCameraPos;
				
				float2 uv1 = (input[0].uv1+input[1].uv1+input[2].uv1)/3;

				float texWidth =_texwidth;
				float texhigh = _texhight;

				float2 intuv =uv1;

				float intx =intuv.x*texWidth-frac(intuv.x*texWidth);
				intuv.x=(intx-fmod(intx,4)+2)/texWidth;
				float inty =intuv.y*texhigh-frac(intuv.y*texhigh);
				intuv.y=(inty-fmod(inty,4)+2)/texhigh;
				
				float xmod = fmod(intx,4);
				float ymod = fmod(inty,4);
				
				float4 mpos1 = float4(unpack(intuv),1);
				
				float4 mpos2 = float4(unpack(intuv+float2(_long*4/texWidth,0)),1);

				float4 mpos3 = float4(unpack(intuv+float2(_long*8/texWidth,0)),1);

				float3 mvec1 = normalize(mpos1.xyz-viewp);
				float3 mvec2 = normalize(mpos2.xyz-viewp);
				
				float4 pos0;
				float4 pos1;
				float4 pos2;
				float4 pos3;
				

				float scale=0.02*_scale*pow((1.0-uv1.x),3)+0.001;

				float3 ziku = mpos1.xyz-mpos2.xyz;
				
				float3 ziku2 = mpos2.xyz-mpos3.xyz;

				if((length(ziku)<0.00)|(length(ziku2)<0.0)){
					pos0 = float4 (0,0,-30,1);
					pos1 = float4 (0,0,-30,1);
					pos2 = float4 (0,0,-30,1);
					pos3 = float4 (0,0,-30,1);
					
				
				}
				else{
					ziku = normalize(ziku);
					float3 h1 = scale*normalize(cross(float3(ziku),mvec1));
					ziku2 = normalize(ziku2);
					float3 h2 = scale*normalize(cross(float3(ziku2),mvec2));
					
					pos0 = mpos1+float4(h1,0);
					pos1 = mpos1-float4(h1,0);
					pos2 = mpos2+float4(h2,0);
					pos3 = mpos2-float4(h2,0);
					

				}	
				
				pos0 = mul(UNITY_MATRIX_VP, pos0);
				pos1 = mul(UNITY_MATRIX_VP, pos1);
				pos2 = mul(UNITY_MATRIX_VP, pos2);
				pos3 = mul(UNITY_MATRIX_VP, pos3);
				
				

				g2f output;
				
				
				float2 uv ;
				float4 uv2 = mpos1;
				float4 uv3 = mpos3;
				
				
				output.uv2 = uv2;
				output.uv3 = uv3;

					{
							
							output.pos =pos0;
							output.uv= pos0;
							output.uv1 =float2(-0.5,0.5);

							outStream.Append(output);
					}
					
					{
						
							output.pos = pos1;
							output.uv= pos1;
							output.uv1 =float2(-0.5,-0.5);

							outStream.Append(output);
					}
					
					
					{
							output.pos = pos2;
							output.uv= pos2;
							output.uv1 =float2(0.5,0.5);
							
							outStream.Append(output);
					}
					
					{
							
							output.pos = pos3;
							output.uv= pos3;
							output.uv1 =float2(0.5,-0.5);
							
							outStream.Append(output);
					}
				
			}
			fout frag (g2f i)
			{
				fout o;

				float intensity = 1;
				
				float s =0.07;
				float n =1;
				float r = n*abs(sin(_Time.y+s*i.uv2.x));
				float g = n*abs(sin(_Time.y+2+s*i.uv2.x));
				float b = n*abs(sin(_Time.y+4+s*i.uv2.x));
				float4 col = float4(r,g,b,intensity);
				o.pixel = col;
				o.depth=(i.uv.z)/(i.uv.w);
				return o;
			}
			ENDCG
		}
	}
}
