//
//  ViewController.m
//  Zombeacon
//
// Copyright (c) 2014, Punch Through Design, LLC
// All rights reserved.
//
//Redistribution and use in source and binary forms, with or without
//modification, are permitted provided that the following conditions are met:
//1. Redistributions of source code must retain the above copyright
//notice, this list of conditions and the following disclaimer.
//2. Redistributions in binary form must reproduce the above copyright
//notice, this list of conditions and the following disclaimer in the
//documentation and/or other materials provided with the distribution.
//3. Neither the name of the <organization> nor the
//names of its contributors may be used to endorse or promote products
//derived from this software without specific prior written permission.

//THIS SOFTWARE IS PROVIDED BY PUNCH THROUGH DESIGN, LLC ''AS IS'' AND ANY
//EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//DISCLAIMED. IN NO EVENT SHALL PUNCH THROUGH DESIGN, LLC BE LIABLE FOR ANY
//DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "ViewController.h"

@interface ViewController ()


@end

@implementation ViewController


@synthesize beaconRegion;
@synthesize zomBeaconRegion;
@synthesize beaconManager;
@synthesize beaconAdvData;
@synthesize locManager;
@synthesize zomBeaconAdvData;
@synthesize lastProximity;
@synthesize proxFilter;
@synthesize isZombeacon;
@synthesize zombieSounds;
@synthesize audioPlayer;
@synthesize zombiePlayFilter;
@synthesize zombieImageBackground;
@synthesize zombieBgColor;
@synthesize rightRecognizer;
@synthesize leftRecognizer;

static const int kMajorUninfected = 0;
static const int kMajorZombie = 1;
static const int kProxFilterCount = 5;
static const int kZombieRssiAtOneMeter = -65;
static const int kZombiePlayDelay = 5;
static const float kLongestBeaconDistance = 4.0;
static const float kLightestZombieAlpha = 0.05f;
NSString *const kBeaconUuid = @"95C8A575-0354-4ADE-8C6C-33E72CD84E9F";
NSString *const kBeaconIdentifier = @"com.punchthrough.zombeacon";


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // init primitives
    proxFilter = 0;
    isZombeacon = NO;
    zombiePlayFilter = 0;
    
    // Set up beacons
    
    // Used to calibrate proximity detection
    NSNumber *zomRssiAtOneMeter = [[NSNumber alloc] initWithInt:kZombieRssiAtOneMeter];
    
    // This UUID is the unique identifier for all Zombeacons and Beacons that monitor for Zombeacons.
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:kBeaconUuid];
    
    // Be sure to register the view controller as the location manager delegate to obtain callbacks
    // for beacon monitoring
    locManager = [[CLLocationManager alloc] init];
    locManager.delegate = self;

    // Initialize the CBPeripheralManager.  Advertising comes later.
    beaconManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                            queue:nil
                                                          options:nil];
    beaconManager.delegate = self;
    
    // These identify the beacon and Zombeacon regions used by CoreLocation
    // Notice that the proximity UUID and identifier are the same for each,
    // but that beacons and zombeacons have different major IDs.  We could
    // have used minor IDs in place of major IDs as well.
    beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                            major:kMajorUninfected
                                                      identifier:kBeaconIdentifier];
    
    zomBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                              major:kMajorZombie
                                                         identifier:kBeaconIdentifier];
    
    // Advertising NSDictionary objects created from the regions we defined
    // We add a local name for each, but it isn't a necessary step
    beaconAdvData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    [beaconAdvData  setObject:@"Healthy Beacon"
                       forKey:CBAdvertisementDataLocalNameKey];
    
    zomBeaconAdvData = [zomBeaconRegion peripheralDataWithMeasuredPower:zomRssiAtOneMeter];
    [zomBeaconAdvData setObject:@"Zombeacon"
                         forKey:CBAdvertisementDataLocalNameKey];
    

    // Set up audio files for playback
    NSURL *zombieSoundMoanUrl = [[NSBundle mainBundle] URLForResource:@"ZombieMoan" withExtension:@"wav"];
    NSURL *zombieSoundAttackedUrl = [[NSBundle mainBundle] URLForResource:@"ZombieAttacked" withExtension:@"wav"];
    NSURL *zombieSoundMoan2Url = [[NSBundle mainBundle] URLForResource:@"ZombieMoan2" withExtension:@"mp3"];
    NSURL *zombieSoundMoan3Url = [[NSBundle mainBundle] URLForResource:@"zombieMoan3" withExtension:@"mp3"];
    
    zombieSounds = [NSArray arrayWithObjects:zombieSoundMoanUrl, zombieSoundMoan2Url,
                                             zombieSoundMoan3Url, zombieSoundAttackedUrl, nil];
    
    // Set up the zombie background picture
    UIImage* zombiePattern = [UIImage imageNamed:@"ZombieTransparent.png"];
    zombieBgColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.3];
    zombieImageBackground = [[UIImageView alloc] initWithImage:zombiePattern];
    zombieImageBackground.frame = self.view.bounds;
    // Initialize the opacity as essentially transparent
    zombieImageBackground.alpha = kLightestZombieAlpha;

    [self.view addSubview:zombieImageBackground];
    [self.view sendSubviewToBack:zombieImageBackground];
    
    // set up gestures to turn on zombification.  Right for zombies, left for healthies
    rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(rightSwipeHandle:)];
    
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rightRecognizer setNumberOfTouchesRequired:1];
    
    leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                               action:@selector(leftSwipeHandle:)];
    
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [leftRecognizer setNumberOfTouchesRequired:1];
    
    [self.view addGestureRecognizer:rightRecognizer];
    [self.view addGestureRecognizer:leftRecognizer];
    
    // Start looking for zombies
    [self startBeaconingUninfected];
}

// Sets device as a beacon or zombeacon
-(void)brainsAreTasty:(bool)deliciousBrains
{
    if ( deliciousBrains )
    {
        // Create a zombeacon
        zombieImageBackground.alpha = 1.0f;
        zombieImageBackground.backgroundColor = zombieBgColor;
        isZombeacon = true;
        [self startBeaconingInfected];
    }
    else
    {
        // Switch back to a healthy lifestyle
        zombieImageBackground.alpha = kLightestZombieAlpha;
        zombieImageBackground.backgroundColor = [UIColor clearColor];
        isZombeacon = false;
        [self startBeaconingUninfected];
    }
    
    // reset filter
    proxFilter = 0;
}

// Starts monitoring for infected beacons and advertises itself as a healthy beacon
-(void)startBeaconingUninfected
{
    // Advertise as a healthy beacon
    [beaconManager stopAdvertising];
    
    [locManager stopMonitoringForRegion:beaconRegion];
    [locManager stopRangingBeaconsInRegion:beaconRegion];
    
    [locManager startMonitoringForRegion:zomBeaconRegion];
    [locManager startRangingBeaconsInRegion:zomBeaconRegion];
    
    [beaconManager startAdvertising:beaconAdvData];
}

// Starts monitoring for uninfected beacons and advertises itself as a zombeacon
-(void)startBeaconingInfected
{
    [locManager stopMonitoringForRegion:zomBeaconRegion];
    [locManager stopRangingBeaconsInRegion:zomBeaconRegion];
    [beaconManager stopAdvertising];
    
    [locManager startMonitoringForRegion:beaconRegion];
    [locManager startRangingBeaconsInRegion:beaconRegion];
    [beaconManager startAdvertising:zomBeaconAdvData];
}

// For debug
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"State Updated");
}

// For debug
-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog(@"Started advertising: %@", error);
}

// This is the method for discovering our beacons.  It looks for the beacons that we defined
// the regions for in ViewDidLoad.
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    // We're only concerned with the nearest beacon, which is always the first object
    if ([beacons count] > 0)
    {
        CLBeacon *nearestBeacon = [beacons firstObject];

        lastProximity = nearestBeacon.proximity;
        
        // Change the opacity of the zombie hand image as an example of using the distance
        // reading returned by CoreLocation
        if ( !isZombeacon)
        {
            //  assuming a reasonable max distance of kLongestBeaconDistance
            float newAlpha = ( kLongestBeaconDistance - nearestBeacon.accuracy ) / kLongestBeaconDistance;
            
            // If accuracy is farther than kLongestBeaconDistance, set opacity to the lightest defined
            if ( newAlpha < kLightestZombieAlpha )
            {
                newAlpha = kLightestZombieAlpha;
            }
            
            zombieImageBackground.alpha = newAlpha;
            NSLog(@"Nearest: %f", nearestBeacon.accuracy);
        }
        
        // Debounce style filter - reset if proximity changes
        // This filter will ensure that a single reading of "Near" or "Immediate" doesn't
        // trigger a sound playback or beacon state switch immediately.  These are
        // George A. Romero style Zombeacons.
        if (nearestBeacon.proximity != lastProximity)
        {
            proxFilter = 0;
        }
        else
        {
            proxFilter++;
        }
        
        // Beacon must be in a certain proximity for a set amount of time before triggering events
        if ( proxFilter >= kProxFilterCount )
        {
            // If you are a zombeacon, and you notice a healthy beacon that is at least near to you,
            // groan as your hunger for brains is all consuming
            if ( isZombeacon
                && ( CLProximityNear == nearestBeacon.proximity
                    || CLProximityImmediate == nearestBeacon.proximity ) )
            {
                zombiePlayFilter++;
                
                 if ( zombiePlayFilter >= kZombiePlayDelay )
                 {
                     // Make sound
                     [self playRandomZombieSound];
                     zombiePlayFilter = 0;
                 }
            }
            // The healthy beacon is bit if the zombeacon is at an immediate distance
            else if ( !isZombeacon && CLProximityImmediate == nearestBeacon.proximity )
            {
                // Become a zombeacon!
                [self playBite];
                [self brainsAreTasty:YES];
            }
        }
        NSLog(@"Found Beacons: %lu", (unsigned long)[beacons count]);
    }
}

// Just for Debug
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Monitoring for region: %@", region.identifier);
}

// Just for Debug
-(void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"Ranging Beacons Fail");
}

// Gesture that sets the state to zombeacon
- (void)rightSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self playBite];
    [self brainsAreTasty:YES];
}

// Gesture that sets the state to a healthy beacon
- (void)leftSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self brainsAreTasty:NO];
}

// Randomized playback using AVFoundation Framework
-(void)playRandomZombieSound
{
    uint16_t randSoundIdx = random() % [zombieSounds count];
    NSError *error = nil;
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:zombieSounds[randSoundIdx]
                                                         error:&error];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
}

// Always play the same sound for a bite
-(void)playBite
{
    NSURL *zombieSoundBiteUrl = [[NSBundle mainBundle] URLForResource:@"ZombieBite2"
                                                        withExtension:@"mp3"];
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:zombieSoundBiteUrl
                                                         error:nil];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
