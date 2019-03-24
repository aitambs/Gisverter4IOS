//
//  ViewController.swift
//  Gisverter
//
//  Created by Aitam Bar-Sagi on 16/03/2019.
//  Copyright © 2019 Aitam Bar-Sagi. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    var choice: UISegmentedControl!
    var inputValues: UITextField!
    var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = UILabel(frame: CGRect(x: 20, y: 20, width: 120, height: 40))
        title.text = "GISVERTER"
        view.addSubview(title)
        
        choice = UISegmentedControl(items: ["ITM To WGS84", "ICS To WGS84", "WGS84 to ITM"])
        choice.frame = CGRect(x: 5, y: 60, width: view.frame.width-10, height: 30)
        choice.selectedSegmentIndex = 0
        view.addSubview(choice)
        
        inputValues = UITextField(frame: CGRect(x: 5, y: 100, width: view.frame.width-10, height: 30))
        inputValues.placeholder = "Type values seperated by space"
        inputValues.keyboardType = .numbersAndPunctuation
        inputValues.autocorrectionType = .no
        view.addSubview(inputValues)
        
        let convertBTN = UIButton(type: .roundedRect)
        convertBTN.frame = CGRect(x: 5, y: 140, width: 120, height: 30)
        convertBTN.setTitle("Convert", for: .normal)
        convertBTN.layer.borderWidth = 1
        convertBTN.layer.cornerRadius = 5
        convertBTN.layer.borderColor = UIColor.black.cgColor
        view.addSubview(convertBTN)
        convertBTN.addTarget(self, action: #selector(convertClicked(sender:)), for: .touchUpInside)
        
        let useGPSBTN = UIButton(type: .roundedRect)
        useGPSBTN.frame = CGRect(x: 130, y: 140, width: 120, height: 30)
        useGPSBTN.setTitle("Use GPS", for: .normal)
        useGPSBTN.layer.borderWidth = 1
        useGPSBTN.layer.cornerRadius = 5
        useGPSBTN.layer.borderColor = UIColor.black.cgColor
        view.addSubview(useGPSBTN)
        useGPSBTN.addTarget(self, action: #selector(useGPSBTNClicked(sender:)), for: .touchUpInside)
        
        resultLabel = UILabel(frame: CGRect(x: 5, y: 180, width: view.frame.width-10, height: 30))
        view.addSubview(resultLabel)
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @objc func convertClicked(sender: UIButton){
        convert()
    }
    
    func convert(){
        let input = NSString(string: inputValues.text!)
        let inputs = input.components(separatedBy: " ")
        if inputs.count != 2 {
            return
        }
        let converter = Converter()
        
        var ints:[Int?] = []
        ints.append(Int(inputs[0]))
        ints.append(Int(inputs[1]))
        
        var doubles:[Double?] = []
        doubles.append(Double(inputs[0]))
        doubles.append(Double(inputs[1]))
        
        switch choice.selectedSegmentIndex {
        case 0:
            if let N = ints[0], let E = ints[1] {
                var result = converter.ITM2WG84(N: N, E: E)
                resultLabel.text="\(result[0]), \(result[1])"
            }
            break
        case 1:
            if let N = ints[0], let E = ints[1] {
                var result = converter.ICS2WG84(N: N, E: E)
                resultLabel.text="\(result[0]), \(result[1])"
            }
            break
        default:
            if let lat = doubles[0], let lon = doubles[1] {
                var result = converter.WG842ITM(lat: lat, lon: lon)
                resultLabel.text="\(result[0]), \(result[1])"
            }
        }
    }
    
    @objc func useGPSBTNClicked(sender: UIButton){
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status{
        case .authorizedAlways:
            print("?!")
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .denied:
            print("Denied")
            break
        case .notDetermined:
            print("Not determined")
            break
        default:
            print("Restricted")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0{
            locationManager.stopUpdatingLocation()
            inputValues.text = "\(locations[0].coordinate.latitude) \(locations[0].coordinate.longitude)"
            choice.selectedSegmentIndex = 2
            convert()
        }
    }
    
}

