# GCellBeacon_example_iOS_Swift
A simple example of monitoring and ranging iBeacon devices in iOS using Swift. This example uses Swift3 and is tested on iOS 10.3.

Before running the app ensure that:
 
 1) The CoreLocation Framework has been added to the project - see https://developer.apple.com/reference/corelocation/cllocationmanager
 2) An appropriate Location Usage description entry has been added to the plist, e.g., Privacy - Location Always Usage Description
 
 Using the CoreLocationManager class in the AppDelegate allows the app to monitor for beacon regions in the background. Ensure that class conforms to the CLLocationMangerDelegate protocol. Use a strong reference to a CLLocationManager instance to monitor for defined beacon regions. When iOS detects that the device has entered a defined region it will deliver a didEnterRegion callback. The app can then start to range beacons - this allows more information about the beacon to be discovered.
 
 When the app goes into the background ranging will stop. However, monitoring for regions will continue and didEnter and didExit region calls will still be made to the app. The documentation form Apple states:


 '''The region monitoring service delivers events normally while an app is running in the foreground or background. (You can use this service for both geographic and beacon regions.) For a terminated iOS app, this service relaunches the app to deliver events. Use of this service requires “Always” authorization from the user.
 
 Beacon ranging delivers events normally while an app is running in the foreground. When your app is in the background, this service delivers events only when the location-updates background mode is enabled for the app and the standard location service is running. (If the beacon region’s notifyEntryStateOnDisplay property is true, waking the device causes the app to range for beacons for a few seconds in the background.) This service does not relaunch iOS apps that have been terminated; however, you can be relaunched by monitoring beacon regions using the region monitoring service.'''
 
 
 See https://developer.apple.com/reference/corelocation/cllocationmanager for details.

