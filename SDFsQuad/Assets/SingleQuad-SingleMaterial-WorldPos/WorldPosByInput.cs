using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WorldPosByInput : MonoBehaviour
{
    [SerializeField] private Material mat;
    [SerializeField] private Transform[] trans;
    private static readonly int InputPos = Shader.PropertyToID("_InputPos");

    //private ComputeBuffer mQuadBuffer;


    private Vector4[] mPositions;
    private static readonly int Length = Shader.PropertyToID("_Length");

    void Start()
    {
        //vector2 => 4byte * 2
        //mQuadBuffer = new ComputeBuffer(mTransforms.Length, 8);
        mPositions = new Vector4[trans.Length];
    }

    void Update()
    {
        for (int i = 0; i < trans.Length; i++)
        {
            mPositions[i] = trans[i].position;
        }
        mat.SetVectorArray(InputPos, mPositions);
        mat.SetFloat(Length, mPositions.Length);
    }

    void OnDisable()
    {
    }
}