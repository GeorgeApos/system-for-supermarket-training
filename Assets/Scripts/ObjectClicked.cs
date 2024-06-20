using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using EPOOutline;
using UnityEngine.Events;

public class ObjectClicked : MonoBehaviour
{
    public UnityEvent objectClicked = new UnityEvent();

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
                    objectClicked.Invoke();
                    FindObjectOfType<GameLogic>().setCurrentlySelectedItem(objectName);
                    if (objectName.Contains("BeerBottle"))
                    {
                        FindObjectOfType<GameLogic>().changeUpPanelText("Τοποθέτησε το αντικείμενο σύμφωνα με το πλανόγραμμα");
                    }
                    GetComponent<Outlinable>().enabled = true;
                }
            }
        }
    }
}
