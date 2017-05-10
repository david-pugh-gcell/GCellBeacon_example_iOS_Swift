# GCellBeacon_example_iOS_Swift
A simple example of monitoring and ranging iBeacon devices in iOS using Swift. This example is built with XCode 8.3.2 using Swift3 and is tested on iOS 10.3.

For more details about the code or iBeacon technology, please contact us at power@gcell.com www.ibeacon.com 

The code uses the CoreLocation framework to monitor for Beacon Regions. When a region is entered the app will start to range beacons in order to get proximity information. This is the recommended approach from Apple. See https://developer.apple.com/reference/corelocation/cllocationmanager for details.

Before running the app ensure that:
 
 1) The CoreLocation Framework has been added to the project - see https://developer.apple.com/reference/corelocation/cllocationmanager
 2) An appropriate Location Usage description entry has been added to the plist, e.g., Privacy - Location Always Usage Description (for background monitoring) or Privacy - Location When in Use Usage Description (for foreground monitoring only)
 
An instance of the CLLocationManager class is used to monitor for definied CLBeaconRegion objects. Data on location events are returned via the LocationManager delegate. When the device enters a defined Beacon Region, it will start to range beacons and will then asynchronously recieve data on the beacon UUID, Major, Minor, RSSI and approximate proximity through the CLLocationManager delegate.

Using the CoreLocationManager class in the AppDelegate allows the app to handle any location data whilst in the background. When the app goes into the background ranging will stop. However, the region monitoring service continue and didEnter and didExit region calls will still be made to the app. 
 
