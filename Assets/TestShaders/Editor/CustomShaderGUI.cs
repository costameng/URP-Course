using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class CustomShaderGUI : ShaderGUI
{
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);

        Material targetMaterial = materialEditor.target as Material;

        bool redify = Array.IndexOf(targetMaterial.shaderKeywords,"_REDIFY") != -1;
        
        EditorGUI.BeginChangeCheck();
        redify = EditorGUILayout.Toggle("_Redify Material", redify);
        EditorGUI.EndChangeCheck();

        if (redify)
        {
            targetMaterial.EnableKeyword("_REDIFY");
        }
        else
        {
            targetMaterial.DisableKeyword("_REDIFY");
        }
    }
}
