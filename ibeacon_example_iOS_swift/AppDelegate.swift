//
//  AppDelegate.swift
//  ibeacon_example_iOS_swift
//
//  Created by David Pugh on 09/05/2017.
//  Copyright © 2017 David Pugh. All rights reserved.
//


/**
 
 Example of adding iBeacon monitoring to an app in Swift. 
 Developed in XCode 8.3.2 using Swift 3 and tested on iPhone 6 running iOS10.3.1
 
 Before running the app ensure that:
 
 1) The CoreLocation Framework has been added to the project https://developer.apple.com/reference/corelocation/cllocationmanager
 2) An appropriate Location Usage description entry has been added to the plist, e.g., Privacy - Location Always Usage Description for background monitoring
 
 The example uses the recommended flow from Apple - Beacon Regions are monitored and when a boundary crossing event is recieved, the app strats to range beacons in that region to gain proximity data. When we leave the region ranging is stopped to save battery and processing power. For a more detailled explaination please contact us at power@gcell.com www.ibeacon.solar
 
 Adding to the AppDelegate allows the app to respond to received beacon region events in the background. Ensure that class conforms to the CLLocationMangerDelegate protocol. Use a CLLocationManager instance to monitor for defined beacon regions. When iOS detects that the device has entered a defined region it will deliver a didEnterRegion callback. The app can then start to range beacons - this allows more information about the beacon to be discovered.
 
 When the app goes into the background ranging will stop. However, monitoring for regions will continue if the Always Allow Location Services permission was granted, and didEnter and didExit region calls will still be made to the app. The documentation form Apple states:


 '''The region monitoring service delivers events normally while an app is running in the foreground or background. (You can use this service for both geographic and beacon regions.) For a terminated iOS app, this service relaunches the app to deliver events. Use of this service requires “Always” authorization from the user.
 
 Beacon ranging delivers events normally while an app is running in the foreground. When your app is in the background, this service delivers events only when the location-updates background mode is enabled for the app and the standard location service is running. (If the beacon region’s notifyEntryStateOnDisplay property is true, waking the device causes the app to range for beacons for a few seconds in the background.) This service does not relaunch iOS apps that have been terminated; however, you can be relaunched by monitoring beacon regions using the region monitoring service.'''
 
 
 See https://developer.apple.com/reference/corelocation/cllocationmanager for details.
 
 */





import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate  {

    var window: UIWindow?
    var locationManager: CLLocationManager = CLLocationManager()    //declare a string instance of the CoreLocationManager class
                                                                    //a local reference is insufficent as many location mamanger tasks run asynchronously
    
    let gCellDefaultUuid = "96530d4d-09af-4159-b99e-951a5e826584" //example proximity UUID
    
    /**
     [CoreLocation CLBeaconRegion]: https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLBeaconRegion_class/index.html#//apple_ref/occ/cl/CLBeaconRegion
     An array of [CoreLocation CLBeaconRegion] objects that the app will scan for. You can either supply an array to this parameter directly or add individual regions using [addBeaconRegion].
     
     */
    var beaconRegions = Set<CLBeaconRegion>()               //Create a set of beacon Regions to monitor.
    
    var changeStateOnce: Bool = false                       //ensure we have received permission to use locn services before restarting scans
    public var monitoringCalled: Bool = false               //flag recording if monitoring for beacons has been called
    let debug = true                                        //control whether feedback is given through NSLog

    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //assign the AppDelegate to the delegate property. The appDelegate has to conform to the CLLocationManagerDelegate protocol to recieve location based updates.
        locationManager.delegate = self
        
        
        //Set up beacon region to you want the app to monitor
        let proxUuid = UUID(uuidString: gCellDefaultUuid)
        //Each different region must have a different identifier
        let beaconRegion1 = CLBeaconRegion(proximityUUID: proxUuid!, identifier: "region1")
        // Add to the set of beacon regions
        beaconRegions.insert(beaconRegion1)

        //Start monitoring for these beacon regions
        startMonitoringForBeaconRegions()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if debug{ print("App has entered background. Ranging will stop and iOS Region Monitoring Service will take over. If the 'Always' location permission has been granted then iOS will wake the app and notify the app when entering or exiting a registered region. If notifyEntryStateOnDisplay is set true for a region, iOS will wake the app and notify it if the device is in that region and the user turns on the display.  ")}
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if debug{ print("App is about to enter foreground. Normal Monitoring and Ranging will now recommence.")}
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


//For convience added as an extension but could easily be a class

extension AppDelegate{
    
    //MARK: Stopping and starting Scans
    /**
     [CoreLocation CLBeaconRegion]: https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLBeaconRegion_class/index.html#//apple_ref/occ/cl/CLBeaconRegion
     
     
     This method starts monitoring for beacon regions defined in the beaconRegions set. Each region is set to notify the app on enter, on exit and if the user turns on the display.
     
     - Warning: Bluetooth Low Energy needs to be ON to search for iBeacons
     
     ### Usage:
     Call to start monitoring for iBeacon Regions, The Beacon regions to scan can be set in anumber of ways:
     
     Create your own beacon regions for [CoreLocation CLBeaconRegion](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLBeaconRegion_class/index.html) and add using beaconRegions.append(beaconRegion)
     
     It sets CLLocationManager to return data whenever the regions are entered and exited.
     
     notifyEntryStateOnDisplay is set to true to allow the state of the region to be determined when a user activites the device display, and to allow a few seconds of ranging when a region is entered whenin background mode.
     
     
     */
    
    open func startMonitoringForBeaconRegions(){
  
        //Check the BLE location settings - we do this at the point of use as recommneded in https://developer.apple.com/reference/corelocation/cllocationmanager#1669513
        if checkDeviceBLSettings() == true{
            if beaconRegions.count == 0{
                NSLog( "No Beacon Regions Defined")
                return
            }

            //for each supplied region, enable relevant notificatiions and start monitoring
            for b in beaconRegions{
                b.notifyOnExit = true //Notify when we enter and exit so we can control ranging
                b.notifyOnEntry = true
                b.notifyEntryStateOnDisplay = true //This causes notifications when the user turns on the display and the device is already inside the region. 
                                                    //It also causes the app to range for a few seconds in the background when a region is entered and iOS wakes the app
                locationManager.startMonitoring(for: b)
            }
        }
        monitoringCalled = true
    }
    
    /**
     
     This function stops ranging and monitoring for a set of defined Beacon Regions

     ## Usage:
     Call to stop monitoring and ranging for iBeacon Regions.
     */

    open func stopMonitoringForBeaconRegions(){
        
        //for each supplied region, stop relevant notificatiions and stop monitoring
        for b in beaconRegions{
            b.notifyOnExit = false
            b.notifyOnEntry = false
            b.notifyEntryStateOnDisplay = false
            locationManager.stopRangingBeacons(in: b)
            locationManager.stopMonitoring(for: b)
        }
        monitoringCalled = false
        
        
    }
    

    
    
    //MARK: CoreLocation locationManager delegate calls
    //CoreLocation locationManager didRangeBeacons callback
    open func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        //Optionally Filter beacon list - this will remove any beacons with an 'unknown' prximity - usually ones iOS hasnt see for a few seconds
        //let beacons = beacons.filter{ $0.proximity != CLProximity.unknown }
        
        //Optionally sort beacons by RSSI
        //let beacons = beacons.sorted(by: {$0.rssi > $1.rssi})
        if debug{print("\(beacons.count) Beacons(s) ranged \(Date())")}
        if(beacons.count > 0) {
            for b in beacons{
                print("\(b.major) \(b.minor) \(b.rssi) \(b)")
            }
        }
        
    }
    
    
    //CoreLocation locationManager didDetermineState callback
    //This is called when a device enters or exits a region and in response to a requestState method call
    open func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        // the app has determined if it is within a region on start up - if it is then start to range
        if state == CLRegionState.inside{
            if debug{print("Determined State of \(region) - Inside this region")}
                locationManager.startRangingBeacons(in: region as! CLBeaconRegion )
 
        }else{
            if debug{print("Determined State of \(region) - Outside region")}
            locationManager.stopRangingBeacons(in: region as! CLBeaconRegion)
        }
        
    }
    
    //CoreLocation locationManager didStartMonitoringForRegion callback
    open func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if debug{print("Monitoring started for region \(region)")}
        //Request the regions initial state - we need to do this as if the app is started and the user is already the region we wont get a Boundary Crossing call.
        //As a result we wont start ranging. notifyEntryStateOnDisplay = true does not overcome this senario.
        //To overcome this initial issue, we request the status of the region once it is successfully registered for monitoring.
        //Data is returned to ther didDetermineState method
        locationManager.requestState(for: region)
        
    }
    
    //CoreLocation locationManager didFailWithError callback
    
    open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Location Manager did fail to start with Error:  \(error)")
    }
    
    //CoreLocation locationManager monitoringDidFailForRegion callback
    open func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        NSLog("Monitoring failed for region \(String(describing: region))")
        
    }
    
    //CoreLocation locationManager rangingDidFailForRegion callback
    open func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        NSLog("Ranging failed for region \(region)")
        
    }
    
    //CoreLocation locationManager didEnterRegion callback
    open func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if debug{print("Entered region \(region)")}
        //You could start ranging here, but didDetermineState is also called so no need to call twice
        //locationManager.startRangingBeacons(in: region as! CLBeaconRegion)
    }
    
    
    
    
    //CoreLocation locationManager didExitRegion callback
    open func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if debug{print("Exited region \(region)")}
        //You could stop ranging here, but didDetermineState is also called so no need to call twice
        //locationManager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }
    
    
    //MARK: CoreBluetooth and Location Services Status callbacks
    
    /**
     This function checks the Location settings on the device, feeds back an error if off or not supported
    Error call back through errorMessage
    See https://developer.apple.com/reference/corelocation/cllocationmanager#1669513 for reference
     */
    
    
    internal func checkDeviceBLSettings() -> Bool {
        
        var errorMessage = ""
        
        if !CLLocationManager.locationServicesEnabled() || (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied) {
            
            errorMessage += "You have denied Location services to this app or they are not turned on! Please enable it for the best experience\n"
            
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            errorMessage += "Not authorised!\nRequesting Authorisation...."
            if(locationManager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization))) {
                locationManager.requestAlwaysAuthorization()
                errorMessage += "requested"
            }
        }
        
        if !CLLocationManager.isRangingAvailable() {
            errorMessage += "Beacon ranging not available!\n"
        }
        
        if !CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            errorMessage += "Beacon ranging not supported!\n"
        }
        
        let errorLen = errorMessage.characters.count
        
        if errorLen > 0 {
            if debug{print("Error:" + errorMessage)}
        }
        
        return errorLen == 0
    }
    
    
    /**
     This function checks the Location Services Authorsation status
     
     - Warning:
     If Location Services is not Authorised no iBeacons will be found
     Always permission needs to be granted to allow background monitoring
     
     */
    
    open func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var shouldIAllow = false
        var locationStatus = ""
        
        switch status {
        case CLAuthorizationStatus.restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.notDetermined:
            locationStatus = "Status not determined"
        case CLAuthorizationStatus.authorizedAlways:
            locationStatus = "Allowed to location Access"
            shouldIAllow = true
        case CLAuthorizationStatus.authorizedWhenInUse:
            locationStatus = "Allowed to Access Location When in Use"
            shouldIAllow = true
        }
        
        if (shouldIAllow == true) {
            if debug{print("Allowed Access: \(locationStatus)")}
            
            // Start location services
            if monitoringCalled && changeStateOnce{
                startMonitoringForBeaconRegions()
            }
        } else {
            if debug{print("Denied access: \(locationStatus)")}
            
        }
        
        changeStateOnce = true
    }
    
    //MARK Listing Existing monitored and ranged regions from CoreLocation
    
    /**
     Prints the set of shared regions monitored by all location manager objects
     ## Usage
     This can be used to see what regions are already registered, to avoid adding again.
     Storing your regions of interest in a set means you can used standard set functionality to efficiently 
     identify any new regions to add. if you add a region a second time the old region is replaced by the new one.
     */
    func listMonitoredRegions(){
        for monitoredRegion in self.locationManager.monitoredRegions as! Set<CLBeaconRegion> {
            print("Monitoring: " + monitoredRegion.strDescription)
        }
    }
    
    /**
     Get a list of the regions currently being ranged by CoreLocation on iOS
     */
    func listRangedRegions(){
        for rangedRegion in self.locationManager.rangedRegions as! Set<CLBeaconRegion> {
            print("Ranging: " + rangedRegion.strDescription)
        }
    }

    
}



