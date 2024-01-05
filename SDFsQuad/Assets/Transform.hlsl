#ifndef Transform
#define Transform

float2 translate(float2 oriPos, float2 offset)
{
    return oriPos + (-offset);
}

float2 rotate(float2 oriPos, float angle)
{
    //0.01745 -> π/180
    float radian = angle * 0.01745f;

    float2x2 m = {
        cos(radian), -sin(radian),
        sin(radian), cos(radian)
    };

    return mul(transpose(m), float2(oriPos));
}

#endif
