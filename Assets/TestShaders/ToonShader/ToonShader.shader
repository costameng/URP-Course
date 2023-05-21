Shader "Custom/Toon"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        [MainColor]_BaseColor ("Base Color", Color) = (1,1,1,1)
        _LevelCount("Level Count", Float) = 3
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque"
            "RenderPipeline"="UniversalPipeline"
            "Queue"="Transparent"
        }
        
        usepass "Universal Render Pipeline/Unlit/DepthOnly"

        Pass
        {
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
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                half4 _BaseColor;
                float _LevelCount;
            CBUFFER_END

            half4 LightingRamp(float3 normal)
            {
                Light light = GetMainLight();
                half NDotL = dot(normal, light.direction);
                //Calculate Diffuse
                half diff = pow(NDotL * 0.5 + 0.5, 2.0);
                half3 ramp = floor(diff * _LevelCount) / _LevelCount;
                half4 c;
                c.rgb = _BaseColor.rgb * light.color.rgb * ramp;
                c.a = 1.0;
                return c;
            }

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normal = IN.normal;
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                return LightingRamp(IN.normal);
            }
            ENDHLSL
        }
    }
}
