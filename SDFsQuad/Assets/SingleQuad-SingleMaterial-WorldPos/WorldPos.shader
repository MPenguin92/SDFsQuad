Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _CircleColor("圆的颜色",Color) = (0.42, 0.58, 1,0)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/SDFsDefine.hlsl"
            #include "Assets/Transform.hlsl"
            #include "Assets/Operate.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _CircleColor;
            CBUFFER_END

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 HCPos : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;

                o.uv = v.uv;
                o.worldPos = TransformObjectToWorld(v.vertex);
                o.HCPos = TransformWorldToHClip(o.worldPos);
                return o;
            }

            float getScaleLerp(float ra)
            {
                return 1 + ((sin(_Time.y * ra) + 1) * 0.5);
            }

            float4 frag(v2f i) : SV_Target
            {
                float timeLerp = sin(_Time.z);
                float2 pos = float2(i.worldPos.x, i.worldPos.y);
                //画一个圆
                DrawData circle;
                circle.opResult = sdCircle(pos + float2(0, timeLerp * 2), 0.5);
                circle.opColor = _CircleColor.rgb;
                //画三个方快便于观察
                const float2 boxSize = float2(1, 1);
                DrawData box;
                box.opResult = sdBox(pos + float2(timeLerp * 0.5, 1.5), boxSize * 0.5 * getScaleLerp(2));
                box.opResult = min(box.opResult,
                                   sdBox(pos + float2(timeLerp * -1, -1.5), boxSize * 0.35 * getScaleLerp(3)));
                box.opResult = min(box.opResult, sdBox(pos + float2(timeLerp, -2.5), boxSize * 0.46 * getScaleLerp(4)));
                box.opColor = float3(0.96, 0.3, 0.35);

                //max求∩ 设置blend颜色
                DrawData maxResult;
                maxResult.opResult = max(circle.opResult, box.opResult);
                maxResult.opColor = circle.opColor  * _CircleColor.a + box.opColor * (1- _CircleColor.a);

                //smooth min 求∪
                const DrawData minResult = opSmoothUnion(circle, box, 0.3);


                DrawData finalResult;
                 //将∩和∪的部分求补,就是相当于把∩的部分挖空
                finalResult.opResult = max(minResult.opResult, -maxResult.opResult);
                finalResult.opColor = minResult.opColor;
                //最终把求补的部分,和挖空的部分再组合起来,都有各自的颜色
                finalResult = opSmoothUnion(finalResult, maxResult, 0.);

                //clip(-finalResult.opResult);
                if (finalResult.opResult < 0.0001)
                    return float4(finalResult.opColor, 1);
                return 1;
            }
            ENDHLSL
        }
    }
}