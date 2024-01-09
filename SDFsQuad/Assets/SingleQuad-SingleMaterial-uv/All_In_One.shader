Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _ScreenResolution("屏幕分辨率",Vector) = (1,1,0,0)
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

            CBUFFER_END
            float2 _ScreenResolution;

            struct appdata
            {
                float3 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 HCPos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.HCPos = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            DrawData style1(float2 uv)
            {
                DrawData data1;
                data1.opResult = sdRing(uv, 0.85, 0.65);
                data1.opColor = float3(0.6, 0.6, 0);

                const float lerpValue = (sin(_Time.w) + 1) * 0.5;
                float length = lerpValue * 0.4;
                DrawData data2;
                data2.opResult = sdBox(rotate(uv, _Time.y * 300), float2(length, length));
                data2.opColor = float3(0, 0.5, 0.5);
                DrawData result = opSmoothUnion(data1, data2, 0.3);
                // clip(-result.opResult);
                // return float4(result.opColor, 1);
                return result;
            }

            float4 render(float2 uv)
            {
                const float lerpValue = (sin(_Time.w) + 1) * 0.5;
                DrawData data1 = style1(uv);
                // data1.opResult = sdCircle(uv, 0.9);
                // data1.opColor = float3(0.9, 0.6, 0.3);
                DrawData data2;
                data2.opResult = sdCircle(uv - float2(0, sin(_Time.y * 3) * 3), 0.45);
                data2.opColor = float3(0.4, 0.7, 0.85);
                DrawData data3;
                data3.opResult = sdRingWithEdge(uv - float2(0, - 2), 0.45, lerpValue * 0.2);
                data3.opColor = float3(0.9, 0.6, 0.3);
                DrawData result = opSmoothUnion(data1, data2, 0.3);
                result = opSmoothUnion(result, data3, 0.3);

                //裁切其它部分
                clip(-result.opResult);
                //or 给其他部分上色
                // if(result.opResult<0.000)
                // {
                //     result.opColor =  float3(1,0,0);
                // }
                
                return float4(result.opColor, 1);
            }

            float4 frag(v2f i) : SV_Target
            {
                //[0,1] => [-1,1] 
                float2 uv = (i.uv - 0.5) * 2;
                //const float screenRatio = _ScreenResolution.x / _ScreenResolution.y;
                //适配高度
                uv = float2(uv.x / (1 / _ScreenResolution.x), uv.y / (1 / _ScreenResolution.y));
                return render(uv);
            }
            ENDHLSL
        }
    }
}