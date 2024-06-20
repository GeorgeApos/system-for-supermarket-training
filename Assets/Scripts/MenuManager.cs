using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MenuManager : MonoBehaviour
{
    public void loadNextScene(string name)
    {
        SceneManager.LoadSceneAsync(name);
    }
}
