///<summary>
/// 概要：このクラスは、トリックアートを表現するためのポストプロセスを行うためのカメラのついている機構に対して、
/// つけるコンポ―ネントの一種です。
/// 
/// 
///
/// <filename>
/// TrickArtPostProcess.cs
/// </filename>
///
/// <creatername>
/// 作成者：堀　明博
/// </creatername>
/// 
/// <address>
/// mailladdress:herie270714@gmail.com
/// </address>
///</summary>


using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrickArtPostProcess : MonoBehaviour 
{
    [SerializeField]
    private Material mat;

    private void Start()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, mat);
    }
}
