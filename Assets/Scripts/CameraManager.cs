using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class CameraManager : MonoBehaviour
{
    public float turnSpeed = 2f;
    public Transform player;

    public GameObject customer;

    
    bool talkingToCustomer = false;
    // Start is called before the first frame update
    void Start()
    {
        customer.transform.parent.gameObject.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButton(0) && !talkingToCustomer)
        {
            float delta = Input.GetAxis("Mouse X") * turnSpeed;
            float deltaY = Input.GetAxis("Mouse Y") * turnSpeed;
            transform.RotateAround(player.position, Vector3.up, delta);
            transform.RotateAround(player.position, Vector3.back, deltaY);
        }
    }

    public void talkingToCustomerScene()
    {
        customer.transform.parent.gameObject.SetActive(true);
        talkingToCustomer = true;
        transform.LookAt(customer.transform);
    }
}
