Shader "Unlit/LineShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Line("BorderLine",Range(0,5)) = 1
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
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				//線分の情報
				float2 line_info:TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Line;
			
			v2f vert (appdata v)
			{
				v2f o;


				//0－1  変換前の頂点の値、 今の線分と頂点の距離、　－値の時は0にする。
				o.line_info = float2(v.vertex.y  - 2.5, max(0, _Line - v.vertex.y));
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);

				//白と黒の逆転表現
				//float distance_result = 1 - step(_Line,i.line_info.x);

				//少し間延びするけど、ひとまずいい感じ動く
				//float up_down_result = 1- max(0,_Line - i.line_info.x) * (distance(cos(_Line),i.line_info.x) + 1.9);


				//実験用  たぶんこれでループするはず。
				//float up_down_result = 1 - max(0,_Line - i.line_info.x) *(cos(fmod(distance(_Line, i.line_info.x),45)));


				//超えてないとこと、超えた時のRangeの2種類 1.0は超えた時の値  白線の広さ
				float _range1 = step(0.0,   fmod(distance(_Line, i.line_info.x),1.0));
				float _range2 = step(0.0,   fmod(distance(_Line, i.line_info.x + 1.0), 1.0));
															//*2は、光からの距離を短くするための数値
				float _distance =   fmod(distance(_Line, i.line_info.x), 1.0) * 2;//fmod(_Line,2.0) - i.line_info.x;
				float _distance2 = fmod(distance(_Line, i.line_info.x + 1.0), 1.0) * 2;
				float _dis1 = _distance;//step(0, _distance) *_distance * _range1;
				float _dis2 = _distance2;//step(0, _distance) * _distance * _range2;

				//両方のいいとこどり
				return 1 - (min(_range1, _range2))  * min(_dis1, _dis2) ; // * _distance;
																	 //return (distance_result  * up_down_result);
			}
			ENDCG
		}
	}
}
