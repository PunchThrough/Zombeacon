Z O M B E A C O N (tm) 
======================

An interactive demo of infectious new tech by Punch Through Design.

info@punchthrough.com
http://punchthrough.com

WTF is a zomBeacon?
-------------------

In short, a zomBeacon is a beacon that turns normal healthy beacons
into other zomBeacons.  Healthy beacons are beacons that cannot
modify other beacons behavior, but are receptive to the zomBeacon
horde.  

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
In the following sections we'll explore how to set up a zomBeacon.

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

Now, create a CLLocation manager in AppDelegate.c:

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

Now, use the CLLocationManager delegate method didDetermineState: forRegion: to capture when a beacon enters its zone.  The rest of the beacon
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

