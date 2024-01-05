#ifndef SDFsDefine
#define SDFsDefine

float sdCircle(float2 p, float r)
{
    return length(p) - r;
}

float sdBox(in float2 p, in float2 b)
{
    float2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sdRing(in float2 p, in float radius1,in float radius2)
{
    float circle = sdCircle(p, radius1);
    float circle2 = sdCircle(p, radius2);
    float s = max(-circle2, circle);
    return s;
}

float sdRingWithEdge(in float2 p, in float radius1,in float edge)
{
    return abs(sdCircle(p,radius1)) - edge;
}


//通用圆角
// float opRound( in vec2 p, in float r )
// {
//     return sdShape(p) - r;
// }

//通用空心
// float opOnion( in vec2 p, in float r )
// {
//     return abs(sdShape(p)) - r;
// }


#endif
