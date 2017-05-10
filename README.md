# GCellBeacon_example_iOS_Swift
A simple example of monitoring and ranging iBeacon devices in iOS using Swift. This example is built with XCode 8.3.2 using Swift3 and is tested on iOS 10.3.

For more details about the code or iBeacon technology, please contact us at power@gcell.com www.ibeacon.com 

The code uses the CoreLocation framework to monitor for Beacon Regions. When a region is entered the app will start to range beacons in order to get proximity information. This is the recommended approach from Apple. 

Before running the app ensure that:
 
 1) The CoreLocation Framework has been added to the project - see https://developer.apple.com/reference/corelocation/cllocationmanager
 2) An appropriate Location Usage description entry has been added to the plist, e.g., Privacy - Location Always Usage Description (for background monitoring) or Privacy - Location When in Use Usage Description (for foreground monitoring only)
 
An instance of the CLLocationManager class is used to monitor for definied CLBeaconRegion objects. Data on location events are returned via the LocationManager delegate. When the device enters a defined Beacon Region, it will start to range beacons and will then asynchronously recieve data on the beacon UUID, Major, Minor, RSSI and approximate proximity through the CLLOcationManager delegate.

Using the CoreLocationManager class in the AppDelegate allows the app to handle any background calls. Ensure that class conforms to the CLLocationMangerDelegate protocol. Use a strong reference to a CLLocationManager instance to monitor for defined beacon regions. When iOS detects that the device has entered a defined region it will deliver a didEnterRegion callback. The app can then start to range beacons - this allows more information about the beacon to be discovered.
 
When the app goes into the background ranging will stop. However, monitoring for regions will continue and didEnter and didExit region calls will still be made to the app. The documentation form Apple states:

 '''The region monitoring service delivers events normally while an app is running in the foreground or background. (You can use this service for both geographic and beacon regions.) For a terminated iOS app, this service relaunches the app to deliver events. Use of this service requires “Always” authorization from the user.
 
Beacon ranging delivers events normally while an app is running in the foreground. When your app is in the background, this service delivers events only when the location-updates background mode is enabled for the app and the standard location service is running. (If the beacon region’s notifyEntryStateOnDisplay property is true, waking the device causes the app to range for beacons for a few seconds in the background.) This service does not relaunch iOS apps that have been terminated; however, you can be relaunched by monitoring beacon regions using the region monitoring service.'''
 
 
 See https://developer.apple.com/reference/corelocation/cllocationmanager for details.

