// The MIT License
// Copyright © 2019 Butadiene
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



Shader "Butadienetrail/input"
{
	
	Properties
	{
		_par ("parameter(random)",float)=0
		_par2 ("parameter2(velocity)",float)=0
		_par3 ("parameter3(gravity)",float)=0.05
	}


	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Overlay" }
		LOD 100

		Pass
		{
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			uniform float _par;
			uniform float _par2;
			uniform float _par3;

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			
			};

			float3 pack(float3 xyz, uint ix) {
					uint3 xyzI = asuint(xyz);
					xyzI = (xyzI >> (ix * 8)) % 256;
					return (float3(xyzI) + 0.5) / 255.0;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex); 
				
				float orcd  = UNITY_MATRIX_P[3][3];
				if(orcd == 0){
				 o.vertex=float4 (0,0,0,1);
				}
				
				o.uv=v.uv;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
					 		 
				float4 posx = mul ( unity_ObjectToWorld, float4(1,0,0,1) );
				
				float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
				float3 output;
				if(i.uv.y>0.5){
					output = objPos.xyz;
				}
				else
				{
					output =float3( _par,_par2,_par3);
				}
					float texWidth = 8;
					float texhigh = 1;

					float xmod = 4*i.uv.x-frac(4*i.uv.x);

					float4 retcol= float4 (pack(output, xmod),1);
				
					return retcol;
			}
			ENDCG
		}
	}
}
