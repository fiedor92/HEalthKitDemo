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
    
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!

    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        }
        else{
            return nil
        }
    }()
    
    func requestAccessToHealthData(){
        let dataTypesToWrite = NSSet(objects:
            HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass))
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
    @IBOutlet weak var weightInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        requestAccessToHealthData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func getData(sender: AnyObject) {
        if healthStore != nil{
            var error:NSError? = NSError()
            var biologicalSexObject = healthStore!.biologicalSexWithError(&error)!.biologicalSex
            println(biologicalSexObject)
            var biologicalSex = " "
            switch biologicalSexObject {
            case .Female: biologicalSex = "Female"
            case .Male: biologicalSex = "Male"
            case .NotSet: biologicalSex = "Not Set"
            case .Other: biologicalSex = "Other"
            }
            sexLabel.text = biologicalSex
            
            var sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            
            let heightSampleQuery = HKSampleQuery(sampleType: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight), predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]){
                (query, results, error) in
                
                if let mostRecentSample = results.first as? HKQuantitySample{
                    let unit = HKUnit(fromString: "m")
                    let value = mostRecentSample.quantity.doubleValueForUnit(unit)
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in self.heightLabel.text =
                        "\(value)\(unit)"
                    })
                    println("debug")
                }
            }
            healthStore?.executeQuery(heightSampleQuery)
        }
    }
    
    func saveData(){
        let weightValue = (weightInput.text as NSString).doubleValue
        let weightToHKQuantity = HKQuantity(unit: HKUnit(fromString: "kg"), doubleValue: weightValue)
        let bodyMassSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass), quantity: weightToHKQuantity, startDate: NSDate(), endDate: NSDate()    )



        healthStore?.saveObject(bodyMassSample!){
            (success, error) in
                if success{
                    println("data saved")
                }else{
                    println(error.description)
                }
        }
    }
    
    @IBAction func saveDataButton(sender: AnyObject) {
        saveData()
    }
}

