//
//  ViewController.m
//  RutasDeTenerife2
//
//  Created by javi on 12/11/15.
//  Copyright © 2015 JAVI. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()


@end

@implementation ViewController

MKPolyline *polyLine;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    self.mapView.delegate = self;
    self.db = [[Database alloc]init];
    [self loadRoutes];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadRoutes{
    self.routes = [[NSMutableArray alloc]init];
    FMResultSet * results = [self.db getInfoMap];
  
    while ([results next]) {
        NSString *nombre = [results stringForColumnIndex:0];
        double inicLat = [results doubleForColumnIndex:1];
        double inicLong = [results doubleForColumnIndex:2];
        double finLat = [results doubleForColumnIndex:3];
        double finLong = [results doubleForColumnIndex:4];
        double durac = [results doubleForColumnIndex:5];
        double dist = [results doubleForColumnIndex:6];
        int dific = [results intForColumnIndex:7];
        NSString *xml = [results stringForColumnIndex:8];
        int identifier = [results intForColumnIndex:9];
        int approved = [results intForColumnIndex:10];
        int region = [results intForColumnIndex:11];
        //(int)_id :(NSString *) name1 :(NSString*)_xml :(float)_dist :(int) _difficulty : (float)_durac :(int)_approved :(int)reg;
        Route *route = [[Route alloc]init:identifier :nombre :xml :dist :dific :durac :approved :region];
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(inicLat, inicLong);
        MKPointAnnotation *marker = [[MKPointAnnotation alloc]init];
        marker.coordinate = position;
        marker.title = [NSString stringWithFormat:@"%d",identifier];
        marker.subtitle = [NSString stringWithFormat:@"%d",approved];
        [route setMarker:marker];
        [self.mapView addAnnotation:marker];
        if ((finLat != 0) && (finLong != 0)){
            CLLocationCoordinate2D position2 = CLLocationCoordinate2DMake(finLat, finLong);
            MKPointAnnotation *marker2 = [[MKPointAnnotation alloc] init];
            marker2.coordinate = position2;
            marker2.title = [NSString stringWithFormat:@"%d",identifier];
            marker2.subtitle = [NSString stringWithFormat:@"%d",approved];
            [route setMarker:marker2];
            [self.mapView addAnnotation:marker2];
        }
        [self.routes addObject:route];
    }
    [results close];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
}

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    if ([annotation isKindOfClass:[MKPointAnnotation class]]){
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        NSString *subtitle = [annotation subtitle];
        int type = [subtitle intValue];
        if (!pinView) {
            // If an existing pin view was not available, create one.

            //NSNumber *number = [NSNumber numberWithLongLong: subtitle.longLongValue];
            //NSUInteger approved = number.unsignedIntegerValue;
            
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            //pinView.animatesDrop = YES;
            pinView.canShowCallout = NO;
            pinView.centerOffset = CGPointMake(0, -pinView.image.size.height / 2);
            //pinView.calloutOffset = CGPointMake(0, 32);
            pinView.image = [self setIcon:type];
        } else {
            pinView.annotation = annotation;
            pinView.image = [self setIcon:type];
        }
        return pinView;
    }
    return nil;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    renderer.strokeColor = [UIColor colorWithRed:204/255. green:45/255. blue:70/255. alpha:1.0];
    renderer.lineWidth = 5;
    
    return renderer;
}

-(Route *)findRouteById:(NSUInteger)identifier{
    Route *r = nil;
    NSUInteger size = [self.routes count];
    for (NSUInteger i = 0; i < size; i++){
        r = [self.routes objectAtIndex:i];
        if ([r getId] == identifier)
            return r;
    }
    return r;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    //MKAnnotation *annotation = [view annotation];
    
    NSString *title = [[view annotation] title];
    int identifier = [title intValue];
    Route *route = [self findRouteById:identifier];
    CLLocationCoordinate2D pos = [[view annotation]coordinate];
    [self clickAction:route :pos];
    NSLog([NSString stringWithFormat:@"TAP: %@",route.getName]);
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    NSString *title = [[view annotation] title];
    int identifier = [title intValue];
    Route *route = [self findRouteById:identifier];
    NSLog([NSString stringWithFormat:@"Close %@ ",route.getName]);
}

-(UIImage *)setIcon: (int)approved{
    
    UIImage *icon = nil;
    switch (approved) {
        case 0:
            icon = [UIImage imageNamed:@"marker_sign_16_normal"];
            break;
        case 1:
            icon = [UIImage imageNamed:@"marker_sign_16_green"];
            break;
        case 2:
            icon = [UIImage imageNamed:@"marker_sign_16_yellow"];
            break;
        case 3:
            icon = [UIImage imageNamed:@"marker_sign_16_red"];
            break;
        default:
            icon = [UIImage imageNamed:@"marker_sign_16_normal"];
            break;
    }
    return icon;
}

- (IBAction)deselect:(id)sender {
    
   }

/**Force didDeselectAnnotationView*/
-(void)closePath{
    NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
    for(id annotation in selectedAnnotations) {
        [self.mapView deselectAnnotation:annotation animated:NO];
    }

}
-(void)clickAction: (Route *)myroute: (CLLocationCoordinate2D)pos{
    //TODO camera move to pos
    NSString *kmlName = [myroute getXmlRoute];
    kmlName =[kmlName substringToIndex:[kmlName length] - 4];
    NSLog(kmlName);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:kmlName ofType:@"kml"];
    NSURL *url = [NSURL fileURLWithPath:path];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        //code to be executed in the background
        self.kmlParser = [[CustomKMLParser alloc] initWithURL:url];
        [self.kmlParser parseKML];
        NSMutableArray *coordinates = self.kmlParser.path;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //code to be executed on the main thread when background task is finished
           // GMSMutablePath *points = [GMSMutablePath path];
            //polyLine = [MKPolyline polylineWithCoordinates:coordinates count:[coordinates count]];

            NSUInteger size = [coordinates count];
            CLLocationCoordinate2D stepCoordinates[size];
            
            for (NSUInteger i = 0; i < size; i++){
                NSValue *value = [coordinates objectAtIndex:i];
                CLLocationCoordinate2D c = [value MKCoordinateValue];
                stepCoordinates[i] = c;
            }
            polyLine = [MKPolyline polylineWithCoordinates:stepCoordinates count:size];
            [self.mapView addOverlay:polyLine];
            });
        });
}
@end
