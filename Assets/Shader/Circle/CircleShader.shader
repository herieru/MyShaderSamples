Shader "Unlit/CircleShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		//角度
		_Rad("SencerLine",Range(0.0,2.0)) = 0.0
		//中心点
		_CenterPos("ObjectPos",Vector) = (0.0,0.0,0.0,0.0)
		//線の長さ
		_LineBold("LineBold",Range(0.0,1.0)) = 0.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 v_pos :TEXCOORD1;	//これの頂点座標
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Rad;
			float4 _CenterPos;
			float _LineBold;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.v_pos = v.vertex;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				
				float _sin = (sin(_Rad));
				float _cos = (cos(_Rad));
				float3 _vec = i.v_pos - _CenterPos;
				float _vec_pos_distance = length(_vec);

				//float ans = step(_sin, _vec.x);// +step(_cos, _vec.y);
				float _ans = step(_sin + _cos,_vec_pos_distance );
				float _ans2 = step (_sin + _cos ,_vec_pos_distance + _LineBold)
				return max(_ans,_ans2);
			}
			ENDCG
		}
	}
}
