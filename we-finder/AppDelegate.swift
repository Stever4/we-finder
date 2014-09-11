//
//  AppDelegate.swift
//  we-finder
//
//  Created by Jake Weiss on 9/7/14.
//  Copyright (c) 2014 Stever4. All rights reserved.
//

import Cocoa
import CoreLocation

class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {
    
    var locManager : CLLocationManager = CLLocationManager()
    var lat: Double = 0.0
    var lon: Double = 0.0
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.startUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        lat = newLocation.coordinate.latitude
        lon = newLocation.coordinate.longitude
    }
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    
}

