using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]
public class ScreenRatio : MonoBehaviour
{
    [SerializeField] private Material mat;
    [SerializeField] private Transform quad;
    private static readonly int ScreenResolution = Shader.PropertyToID("_ScreenResolution");

    void Update()
    {
        var lossyScale = quad.lossyScale;
        mat.SetVector(ScreenResolution,new Vector4(lossyScale.x,lossyScale.y));
    }
}