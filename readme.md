Z O M B E A C O N (tm) 
======================

An interactive demo of infectious new tech by Punch Through Design.

info@punchthrough.com

http://punchthrough.com

WTF is a zomBeacon?
-------------------

In short, a zomBeacon is a beacon that turns normal healthy beacons
into other zomBeacons.  Healthy beacons are beacons that are receptive 
to the zomBeacon horde.

Proximity event driven behavior
-------------------------------

A healthy beacon turns into a zomBeacon when it is close to a zomBeacon.  
We further identify how close a healthy beacon is to sensed zomBeacons by changing the opacity of a zombie hand background image; if it's pretty far away from the zomBeacon, the hand is barely visible, and if it's near, say 3-4 meters, the hand is impossible to miss.  

A zomBeacon will make its all consuming hunger for brains known to the wider world by audibly groaning when it senses that a healthy beacon is near.

Why?
----

First and foremost, we've createad this project to help others 
learn about iBeacon technology and how to use the iOS frameworks
behind it.  Important sections of code will be explained in this
ReadMe and in the code itself.  

Secondly, this project aims to explore the idea of beacons that
transform the behavior or other beacons.  iBeacons are often thought
of as a static entity--a device that is configured to broadcast 
a particular message throughout its lifespan.  What if the beacon
could modify its behavior due to other beacons it senses in the 
environment?  Instead of a device that is stuck transmitting 
"Hello, world!" forever, it might start by saying "Hello, world!" 
and then "Run away!", and, finally, "Braaaaiiins!"  Or maybe your device enters the world transmitting "A good brain would really be nice today," 
when suddenly, when a healthy "Hello, world!" beacon appears, it triggers an internal event, such as an all consuming hunger for brains.  

How?
----
In the following sections we'll explore how to set up a bi-directional
beacon.  We'll mainly focus on beacon setup, and leave some of the
other features of the code, such as gesture based events, to the comments in the code itself.

### CoreLocation and CoreBluetooth

CoreLocation and CoreBluetooth are the two frameworks you will need
to add to your project to begin working with iBeacons on an iOS
device.  Be sure to add them under "Linked Frameworks and Libraries."

### Setting up Beacon notifications

Setting up your iOS project to send beacon notifications is relatively
straightforward.  We start by making AppDelegate a CLLocationManager
delegate:

AppDelegate.h
```objective-c
@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>
```

Now, create a CLLocation manager in AppDelegate.m:

```objective-c
@interface AppDelegate()

@property (strong, nonatomic) CLLocationManager *locManager;

@end

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;
    
    return YES;
}
```

Use the CLLocationManager delegate method didDetermineState: forRegion: to capture when a beacon enters its zone.  The rest of the beacon
setup will happen later, in our ViewController.

```objective-c
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{

    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    if(state == CLRegionStateInside)
    {
        notification.alertBody = NSLocalizedString(@"Braaaiiiiins", @"");
    }
    else
    {
        return;
    }
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}
```

### ViewController

The view controller also needs to be configured as a CLLocationManager delegate to capture when specific beacons are in range so that you
can get their distance and other properties.  In addition to being
a CLLocationManager delegate, we have it act as a CBPeripheralManager delegate so we can capture beacon setup events useful for debugging.

```objective-c
@interface ViewController () <CBPeripheralManagerDelegate, CLLocationManagerDelegate>
```

Now we setup the CoreLocation and CoreBluetooth associated properties

```objective-c
// Location Manager Associated Types and primitives
@property (strong, nonatomic) CLLocationManager *locManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLBeaconRegion *zomBeaconRegion;
@property (assign, nonatomic) CLProximity lastProximity;

// Peripheral Manager Associated Types
@property (strong, nonatomic) CBPeripheralManager *beaconManager;
@property (strong, nonatomic) NSMutableDictionary *beaconAdvData;
@property (strong, nonatomic) NSMutableDictionary *zomBeaconAdvData;
```

We setup some constants to help us configure the beacons.  These constants refer to fields in the CLBeaconRegion class.

```objective-c
// Beacon configuration
static const int kMajorUninfected = 0;
static const int kMajorZombie = 1;
NSString *const kBeaconUuid = @"95C8A575-0354-4ADE-8C6C-33E72CD84E9F";
NSString *const kBeaconIdentifier = @"com.punchthrough.zombeacon";
```

kBeaconUuid is the proximity UUID assigned to our zomBeacons and beacons
that recognize our zomBeacons.  These are the IDs that differentiate your beacon types from other beacon types.  So if you are creating an app that responds to your beacons, you would differentiate your beacons from other beacons by using the proximity UUID.  You can generate your own UUID by typing 'uuidgen' into your OS X terminal. 

After your app identifies your beacon proximity UUID, you can provide further information about the beacon by using the MajorID and MinorID properties.  In this example, we're just using the MajorID to state whether the beacon is a healthy beacon (0) or a zomBeacon (1).  

Finally, the identifier gives CoreLocation a means to associate the beacon with your project.

Next, we initialize our CoreLocationManager, PeripheralManager, and assign the ViewController as a delegate to both of them in our ViewDidLoad method:

```objective-c
    // Be sure to register the view controller as the location manager delegate to obtain callbacks

    // for beacon monitoring
    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;

    // Initialize the CBPeripheralManager.  Advertising comes later.
    self.beaconManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                            queue:nil
                                                          options:nil];
    self.beaconManager.delegate = self;
```

Now that these are ready to go, we set up our beacon regions:

```objective-c
    // These identify the beacon and Zombeacon regions used by CoreLocation
    // Notice that the proximity UUID and identifier are the same for each,
    // but that beacons and zombeacons have different major IDs.  We could
    // have used minor IDs in place of major IDs as well.
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                            major:kMajorUninfected
                                                      identifier:kBeaconIdentifier];

    self.zomBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                              major:kMajorZombie
                                                         identifier:kBeaconIdentifier];

```

The CLBeaconRegion is kind enough to help in creating the advertising configuration for our beacons.  peripheralDataWithMeasurePower: allows us to 
calibrate our beacons at 1 meter.  Experimentally, we found that an RSSI
value of -65db was read between iPhones while we were standing a meter apart.

```objective-c
    // Advertising NSDictionary objects created from the regions we defined
    // We add a local name for each, but it isn't a necessary step
    self.beaconAdvData = [self.beaconRegion peripheralDataWithMeasuredPower:zomRssiAtOneMeter];
    [self.beaconAdvData  setObject:@"Healthy Beacon"
                            forKey:CBAdvertisementDataLocalNameKey];

    self.zomBeaconAdvData = [self.zomBeaconRegion peripheralDataWithMeasuredPower:zomRssiAtOneMeter];
    [self.zomBeaconAdvData setObject:@"Zombeacon"
                              forKey:CBAdvertisementDataLocalNameKey];
```

That's it.  We're ready to start beaconing.  To do so, we give CBPeripheralManager our beacon advertising data and tell it to start advertising.  Then, we tell CoreLocation manager to start looking for a particular type of beacon.  Notice we use both startMonitoringForRegions: and startRangingBeaconsInRegion:.  startMonitoringForRegion will notify us whenever we enter or leave a beacons zone, while startRangingBeaconsInRegion will give us more proximity information about the beacons it locates.

```objective-c
    // Start looking for zombies
    [self startBeaconingUninfected];
```

```objective-c
// Starts monitoring for infected beacons and advertises itself as a healthy beacon
-(void)startBeaconingUninfected
{
    // Advertise as a healthy beacon
    [self.beaconManager stopAdvertising];

    [self.locManager stopMonitoringForRegion:self.beaconRegion];
    [self.locManager stopRangingBeaconsInRegion:self.beaconRegion];

    [self.locManager startMonitoringForRegion:self.zomBeaconRegion];
    [self.locManager startRangingBeaconsInRegion:self.zomBeaconRegion];

    [self.beaconManager startAdvertising:self.beaconAdvData];
}
```

Whenever CoreLocation manager finds one of our zomBeacons, it will call the delegate method didRangeBeacons: inRegion:.  CoreLocation will give us a list of beacons that match the beacon region we defined; it doesn't just look for the proximity ID, but for the major and minor IDs we defined as well.

```objective-c
// This is the method for discovering our beacons.  It looks for the beacons that we defined
// the regions for in ViewDidLoad.
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    // We're only concerned with the nearest beacon, which is always the first object
    if ([beacons count] > 0)
    {
        CLBeacon *nearestBeacon = [beacons firstObject];

```

The code above gets the beacon count and grabs the first beacon from the list which is always the one closest to us.

Now that we have a CLBeacon object, we can query it for an approximate distance to us by using the CLBeacon accuracy property.  We're using the distance in our code to set the opacity of the zombie hand that's used as our image background. The opacity gives a sense of distance to sensed zombeacons:

```objective-c
            //  assuming a reasonable max distance of kLongestBeaconDistance
            float newAlpha = ( kLongestBeaconDistance - nearestBeacon.accuracy ) / kLongestBeaconDistance;
```

Lastly, our event driven behavior, and our beacon role switching is determined by querying the CLBeacon for its proximity, which is split up into four areas: Immediate, Near, Far, and Unknown.  

```objective-c
            // If you are a zombeacon, and you notice a healthy beacon that is at least near to you,
            // groan as your hunger for brains is all consuming
            if ( self.isZombeacon
                && ( CLProximityNear == nearestBeacon.proximity
                    || CLProximityImmediate == nearestBeacon.proximity ) )
            {
                self.zombiePlayFilter++;

                 if ( self.zombiePlayFilter >= kZombiePlayDelay )
                 {
                     // Make sound
                     [self playRandomZombieSound];
                     self.zombiePlayFilter = 0;
                 }
            }
            // The healthy beacon is bit if the zombeacon is at an immediate distance
            else if ( !self.isZombeacon && CLProximityImmediate == nearestBeacon.proximity )
            {
                // Become a zombeacon!
                [self playBite];
                [self brainsAreTasty:YES];
            }
```

We're performing some simple filtering of our events, so that we don't, say, keep groaning for brains every second that this method is called.  For a zomBeacon, we check whether we are at least near a healthy beacon.  If we are, we groan as our hunger for brains is insatiable.  If we're a healthy beacon, and we notice a zomBeacon that's immediate to us, it's too late for us--a bite is registered and we switch our role to that of a zomBeacon.    

Have fun exploring the rest of the code!  Hopefully this gives enough info to get up and running with iBeacon technology and helps others to continue exploring this idea of dynamic beaconing.

### License Stuff (FreeBSD based)

Copyright (c) 2014, Punch Through Design, LLC
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

3. Neither the name of the <organization> nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY PUNCH THROUGH DESIGN, LLC ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL PUNCH THROUGH DESIGN, LLC BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

