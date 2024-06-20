using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class GameLogic : MonoBehaviour
{
    public TMP_Text upPanelText;
    public Image tick1;
    public Image tick2;
    public Image tick3;

    public Sprite ckeckMark;
    public Sprite cancelMark;

    public GameObject wrongPlacedObject;

    public GameObject item1;
    public GameObject item2;

    public GameObject panelDialog;

    public Image buttonBackground;

    bool task1 =false;
    bool task2 = false;
    bool task3 = false;

    string currentlySelectedItem;
    // Start is called before the first frame update
    void Start()
    {
        panelDialog.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void task1Completed(bool success)
    {
        task1 = true;
        if (success)
        {
            tick1.sprite = ckeckMark;
            tick1.color = Color.green;
            item1.SetActive(false);
        }
        else
        {
            tick1.sprite = cancelMark;
            tick1.color = Color.red;
            item2.SetActive(false);
        }
        checkForVictory();
    }
    public void task2Completed(bool success)
    {
        task2 = true;
        if (success)
        {
            tick2.sprite = ckeckMark;
            tick2.color = Color.green;
            item2.SetActive(false);
        }
        else
        {
            tick2.sprite = cancelMark;
            tick2.color = Color.red;
            item1.SetActive(false);
        }
        checkForVictory();
    }
    public void task3Completed(bool success)
    {
        task3 = true;
        if (success)
        {
            tick3.sprite = ckeckMark;
            tick3.color = Color.green;
        }
        else
        {
            tick3.sprite = cancelMark;
            tick3.color = Color.red;
        }
        checkForVictory();
    }

    public void checkForVictory()
    {
        if (task1 && task2 && task3)
        {           
            FindObjectOfType<CameraManager>().talkingToCustomerScene();
            upPanelText.text = "Προσοχή! Κάποιος πελάτης θέλει να σου μιλήσει!";
            panelDialog.SetActive(true);
        }
        if(task1 && task2)
        {
            upPanelText.text = "Επίλεξε το αντικείμενο στο ράφι που είναι λάθος με βάση το πλανόγραμμα";
            wrongPlacedObject.GetComponent<ObjectClicked>().enabled = true;
        }
    }

    public void changeUpPanelText(string text)
    {
        upPanelText.text = text;
    }

    public string getCurrentlySelectedItem()
    {
        return currentlySelectedItem;
    }

    public void setCurrentlySelectedItem(string name)
    {
        currentlySelectedItem = name;
    }

    public void selectedAnswerInCustomer(int buttonNum)
    {
        if (buttonNum != 3)
        {
            upPanelText.text = "Δυστυχώς αυτή δεν είναι μια σωστή απάντηση";
        }
        else
        {
            upPanelText.text = "Συγχαρητήρια! Αυτή είναι η σωστή απάντηση!";
        }
        buttonBackground.color = Color.green;
    }
}
