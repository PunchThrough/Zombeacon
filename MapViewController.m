//
//  MapViewController.m
//  Zombeacon
//
//  Created by Connor Dunne on 1/8/15.
//  Copyright (c) 2015 Punch Through Design. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>


@interface MapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMap];
    // Do any additional setup after loading the view.
    
    //add something to user defaults for fun
    
//    NSArray *coordTuple = @[[NSNumber numberWithDouble:37.74], [NSNumber numberWithDouble:-122.435]];
//    [self addTupleToUserDefaults:coordTuple];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initMap{
    //set boundaries
//    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(37.73, -122.4375); //sfo
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(35.27, -120.66); //slo
    MKCoordinateSpan coordSpan = MKCoordinateSpanMake(.21, .1);
    MKCoordinateRegion coordRegion = MKCoordinateRegionMake(centerCoordinate, coordSpan);
    [self.mapView setRegion:coordRegion];
    
    
    //add previous annotations (of iBeacons)
    
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:centerCoordinate];
    
    
    
    //Get list of lat, long coords from NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *coordArray = [defaults objectForKey:@"coords"];
    
    for (NSArray *tuple in coordArray){
        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake([tuple[0] doubleValue], [tuple[1] doubleValue]);
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:newCoord];
        
        [self.mapView addAnnotation:annotation];
    }
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
