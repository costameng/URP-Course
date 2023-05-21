Shader "Custom/TintColor"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _TintColor("Tint Color", Color) = (1,1,1,1)
        _TintStrength("Tint Strength", Range(0,1)) = 0.5
        _Brightness("Brightness", Range(0,3)) = 1
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque"
//            "RenderPipeline"="UniversalPipeline"
//            "Queue"="Transparent"
        }
        
        usepass "Universal Render Pipeline/Unlit/DepthOnly"

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
            };

            TEXTURE2D(_MainTex);
            CBUFFER_START(UnityPerMaterial)
                SAMPLER(sampler_MainTex);
                float4 _MainTex_ST;
                float4 _TintColor;
                float _TintStrength;
                float _Brightness;
            CBUFFER_END

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformWorldToHClip(positionWS);
                // OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                half4 texel = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                half gray = (texel.r + texel.g + texel.b) / 3.0;
                half4 tinted = _TintColor * gray * _Brightness;
                half4 col = lerp(texel, tinted, _TintStrength);
                return col;
            }
            ENDHLSL
        }
    }
}
