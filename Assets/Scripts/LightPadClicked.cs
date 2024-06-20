using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using EPOOutline;
using UnityEngine.Events;

public class LightPadClicked : MonoBehaviour
{
    public UnityEvent success = new UnityEvent();
    public UnityEvent fail = new UnityEvent();
    public string acceptedObjects;

    public GameObject bottleToSpawn;

    private string objectName;
    // Start is called before the first frame update
    void Start()
    {
        objectName = transform.name;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit))
            {
                Debug.Log(hit.transform.name);
                //Select stage    
                if (hit.transform.name.Equals(objectName))
                {
                    if (FindObjectOfType<GameLogic>().getCurrentlySelectedItem() != null)
                    {
                        if (FindObjectOfType<GameLogic>().getCurrentlySelectedItem().Contains(acceptedObjects))
                        {
                            success.Invoke();
                            //FindObjectOfType<GameLogic>().task1Completed(true);
                        }
                        else
                        {
                            if (acceptedObjects.Equals("something"))
                            {
                                if (FindObjectOfType<GameLogic>().getCurrentlySelectedItem().Equals("BeerBottle1"))
                                {
                                    FindObjectOfType<GameLogic>().task1Completed(false);
                                }
                                else
                                {
                                    FindObjectOfType<GameLogic>().task2Completed(false);
                                }
                            }
                            fail.Invoke();
                            //FindObjectOfType<GameLogic>().task1Completed(false);
                        }
                        if (bottleToSpawn)
                        {
                            GameObject.Instantiate(bottleToSpawn, transform.position, Quaternion.identity);
                        }
                        
                        gameObject.SetActive(false);
                    }
                }
            }
        }
    }

    public void turnOnLightPads()
    {
        GetComponent<Outlinable>().enabled = true;
    }
}
