//
//  ViewController.h
//  BeaconTest
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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>


@interface ViewController : UIViewController <CBPeripheralManagerDelegate, CLLocationManagerDelegate, UITextFieldDelegate>
{
    

}

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLBeaconRegion *zomBeaconRegion;
@property (strong, nonatomic) CBPeripheralManager *beaconManager;
@property (strong, nonatomic) NSMutableDictionary *beaconAdvData;
@property (strong, nonatomic) NSMutableDictionary *zomBeaconAdvData;
@property (strong, nonatomic) CLLocationManager *locManager;
@property (assign, nonatomic) CLProximity lastProximity;
@property (assign, nonatomic) int proxFilter;
@property (assign, nonatomic) bool isZombeacon;
@property (strong, nonatomic) NSArray *zombieSounds;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (assign, nonatomic) int zombiePlayFilter;
@property (strong, nonatomic) UIImageView *zombieImageBackground;
@property (strong, nonatomic) UIColor *zombieBgColor;
@property (strong, nonatomic) UISwipeGestureRecognizer *rightRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer *leftRecognizer;

@end
