///このシェーダーは、頂点を変形させて、弾丸のように、いい感じに、先をとがらせるためのシェーダーです。
///
///
///
///
///
///
///

Shader "Unlit/BalletShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Dir("MoveDirect",VECTOR) = (0,0,0,0)

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
				float3 distance :TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float3 _Dir;
			
			v2f vert (appdata v)
			{
				v2f o;

				//半分の方向の値の取得　＝＞　これは、Sphereの形状に合わせた頂点情報
				float3 _normalize_dir = normalize(_Dir)  * step(0,length(_Dir));
				float _distance = v.vertex;// -_Dir; //distance(_Dir , v.vertex);
				float _vertex_dir = (_normalize_dir - v.vertex) * _distance;
				//近いほど値を小さくしたい
				o.distance = abs(v.vertex - _Dir);// _Dir - v.vertex;

				float3 _at = float3(_distance, _distance, _distance);

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
				UNITY_APPLY_FOG(i.fogCoord, col);
				return i.distance.x;
			}
			ENDCG
		}
	}
}
