Shader "Unlit/LineShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Line("BorderLine",Range(0,5)) = 1
		_DRange("DisplayRange",Range(0.0,1.0)) = 0.2
		_PowRange("Pow",Range(0,20)) = 10
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
			float _DRange;
			//べき乗の回数
			int _PowRange;


			v2f vert (appdata v)
			{
				v2f o;


				//頂点の位置を調整するためのもの　0.5は頂点の色の違い -0.5は上の頂点を見たいため。
				o.line_info = float2(v.vertex.y + 0.5 , v.vertex.y - 0.5);
				//o.line_info = float2(v.vertex.x, v.vertex.y);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				//調整されたLineの高さ 0-1.0の範囲で納める
				float _adjustedLine = fmod(_Line ,1.0);
				
				//ラインの一致している部分
				//頂点の値の一致する部分
				float _lineHmatch1 = step(i.line_info.x, _adjustedLine);
				//足された側の一致したところ
				float _lineHmatch2 = step(i.line_info.y,_adjustedLine);

				//描画を行う範囲
				float _range1 =  step(_adjustedLine - i.line_info.x, _DRange);
				float _range2 =  step(_adjustedLine - i.line_info.y,_DRange);
	

				//距離による色の減衰  描画をあくまでも↑が白くしたいので１から引く　範囲を明確にしたいのでべき乗で調整
				float _distance1 = 1 - distance(i.line_info.x, _adjustedLine);
				_distance1 = pow(_distance1 , _PowRange);

				float _distance2 = 1 - distance(i.line_info.y, _adjustedLine);
				_distance2 = pow(_distance2, _PowRange);


				float _ans1 = _lineHmatch1 * _range1 *_distance1;
				float _ans2 = _lineHmatch2 * _range2 *_distance2;

				return max(_ans1, _ans2);

			}
			ENDCG
		}
	}
}
