Shader "Custom/ToonOutline"
{
    Properties
    {
        _OutlineWidth("Outline Width", Range(0.0,0.01)) = 0.005
        _OutlineColor ("Outline Color", Color) = (0.5,0.5,0.5,1)
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
            Cull Front
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normal       : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
            };
            
            CBUFFER_START(UnityPerMaterial)
                half _OutlineWidth;
                half4 _OutlineColor;
            CBUFFER_END

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                IN.positionOS.xyz += IN.normal * _OutlineWidth;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                return _OutlineColor;
            }
            ENDHLSL
        }
    }
}
