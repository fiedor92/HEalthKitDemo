//
//  ViewController.swift
//  HealthKitTest
//
//  Created by appacmp on 16/08/15.
//  Copyright (c) 2015 Maciej Fiedorowicz. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        }
        else{
            return nil
        }
    }()
    
    func requestAccessToHealthData(){
        let dataTypesToWrite = NSSet()
        let dataTypesToRead = NSSet(objects:
            HKCharacteristicType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex),
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        )
        
        if healthStore != nil {
            healthStore!.requestAuthorizationToShareTypes(dataTypesToWrite as Set<NSObject>, readTypes: dataTypesToRead as Set<NSObject>){
                (success, error) -> Void in
                if success {
                    println("Success")
                }else{
                    println(error.description)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        requestAccessToHealthData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

