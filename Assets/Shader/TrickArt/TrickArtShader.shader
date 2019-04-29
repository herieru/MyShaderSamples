//このシェーダーは、トリックアートの一種のシェーダーです。
//具体的には、カメラからレンダリングされた値に対して、デプスと中心点のデプスを比較を行い
//その比較に対して、縞々の線を、いい感じに、ゆがめて、それっぽく行うためのものです。
//これは、あたかも見えないやつが、そこに実現しているように見せるためのポストエフェクトの
//前段階＋研究段階のものです。
//
//

Shader "PostEffect/TrickArtShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		//UVにおいての線の描画間隔　2で0.5(uv単位)間隔
		_LineInterVal("LineInterval",Range(1,30)) = 1
		//UVにおいての許容される範囲
		_AcceptUV("AcceptUV",Range(0.01,0.02)) = 0.02
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			sampler2D _MainTex;
			//デプス用のテクスチャ
			sampler2D _CameraDepthTexture;

			//ラインの間隔
			int _LineInterVal;
			float _AcceptUV;

			//調整された塗るべき間隔UV
			float adjustLineUv;
			


			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_CameraDepthTexture, i.uv);
				// just invert the colors
				col.rgb = 1 - col.rgb;

				float _uv_interval = 1.0 / _LineInterVal;
				//線を描画する。
				float _mod_interval = fmod(i.uv.y, _uv_interval);

				col = step(_mod_interval, _AcceptUV);
			

				return col;
			}
			ENDCG
		}
	}
}
