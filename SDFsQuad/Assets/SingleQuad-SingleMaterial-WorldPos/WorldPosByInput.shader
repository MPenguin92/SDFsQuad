Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _CircleColor("圆的颜色",Color) = (0.42, 0.58, 1,0)
        _InputWPos("世界坐标",Vector) = (0,0,0,0)
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
            float _Length;
            float4 _InputPos[4];
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

                DrawData circle;
                circle.opResult = sdCircle(pos + float2(0, timeLerp * 2), 0.5);
                circle.opColor = float3(0.6, 0.2, 0.3);

                DrawData circleInput;
                circleInput.opResult = sdCircle(pos - _InputPos[0].xy, 0.5);
                circleInput.opColor = _CircleColor.rgb;
                
                DrawData finalResult = opSmoothUnion(circle, circleInput, 0.3);
               
                
                for (int ind = 1; ind < _Length; ++ind)
                {
                    circleInput.opResult = sdCircle(pos - _InputPos[ind], 0.5);
                    circleInput.opColor = _CircleColor.rgb;
                    finalResult = opSmoothUnion(finalResult, circleInput, 0.3);
                }
                //clip(-finalResult.opResult);
                if (finalResult.opResult < 0.0001)
                    return float4(finalResult.opColor, 1);
                return 1;
            }
            ENDHLSL
        }
    }
}