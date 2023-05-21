// 此着色器将在网格上绘制纹理。
Shader "Custom/URPUnlitShaderTexture"
{
    // _BaseMap 变量在材质的 Inspector 中显示为一个名为
    // Base Map 的字段。
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white"
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        usepass "Universal Render Pipeline/Unlit/DepthOnly"
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                // uv 变量包含给定顶点的纹理上的
                // UV 坐标。
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                // uv 变量包含给定顶点的纹理上的
                // UV 坐标。
                float2 uv           : TEXCOORD0;
            };

            // 此宏将 _BaseMap 声明为 Texture2D 对象。
            TEXTURE2D(_BaseMap);
            // This macro declares the sampler for the _BaseMap texture.
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                // 以下行声明 _BaseMap_ST 变量，以便可以
                // 在片元着色器中使用 _BaseMap 变量。为了
                // 使平铺和偏移有效，有必要使用 _ST 后缀。
                float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                // TRANSFORM_TEX 宏执行平铺和偏移
                // 变换。
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // SAMPLE_TEXTURE2D 宏使用给定的采样器对纹理进行
                // 采样。
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                return color;
            }
            ENDHLSL
        }
    }
}