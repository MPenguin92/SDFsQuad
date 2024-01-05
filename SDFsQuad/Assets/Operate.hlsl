#ifndef Operate
#define Operate

struct DrawData
{
    float opResult;
    float3 opColor;
};

struct DrawDataAlpha
{
    float opResult;
    float4 opColor;
};

float random(float2 v)
{
    return frac(sin(dot(v, float2(12.9898, 78.233))) * 43758.5453123);
}

DrawData opSmoothUnion(DrawData d1, DrawData d2, float k)
{
    DrawData result;
    float h = clamp(0.5 + 0.5 * (d2.opResult - d1.opResult) / k, 0.0, 1.0);
    k = k * h * (1.0 - h);
    result.opResult = lerp(d2.opResult, d1.opResult, h) - k;
    result.opColor = lerp(d2.opColor, d1.opColor, h) - k;

    return result;
}
#endif
