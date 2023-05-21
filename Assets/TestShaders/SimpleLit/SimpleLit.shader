Shader "Custom/SimpleLit"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        [MainColor]_BaseColor ("Base Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque"
            "RenderPipeline"="UniversalPipeline"
//            "Queue"="Transparent"
        }
        
        usepass "Universal Render Pipeline/Unlit/DepthOnly"

        Pass
        {
            Name "ForwardLit"
            Tags {
                "LightMode"="UniversalForward"
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normal       : NORMAL;
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float3 normal       : TEXCOORD0;
                float2 uv           : TEXCOORD1;
                float3 positionWS   : TEXCOORD2;
            };

            TEXTURE2D(_MainTex);
            CBUFFER_START(UnityPerMaterial)
                SAMPLER(sampler_MainTex);
                float4 _MainTex_ST;
                half4 _BaseColor;
                float _LevelCount;
            CBUFFER_END

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformWorldToHClip(positionWS);
                OUT.positionWS = positionWS;
                OUT.normal = IN.normal;
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                half3 texel = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                Light light = GetMainLight();
                half3 lightColor = LightingLambert(light.color, light.direction, IN.normal);
                half3 c = texel * lightColor;

                clip(frac(IN.positionWS.y * 10.0) - 0.5);
                return half4(c, 1.0);
            }
            ENDHLSL
        }
    }
}
