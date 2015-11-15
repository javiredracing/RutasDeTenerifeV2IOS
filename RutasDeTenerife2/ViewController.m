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
UIImage *imageRed;
UIImage *imageYellow;
UIImage *imageGreen;
UIImage *imageBrown;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    self.mapView.delegate = self;
    self.db = [[Database alloc]init];
    imageBrown = [UIImage imageNamed:@"marker_sign_16_normal"];
    imageYellow = [UIImage imageNamed:@"marker_sign_16_yellow"];
    imageGreen = [UIImage imageNamed:@"marker_sign_16_green"];
    imageRed = [UIImage imageNamed:@"marker_sign_16_red"];
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
    NSMutableArray *annotations = [[NSMutableArray alloc]init];
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
        //[self.mapView addAnnotation:marker];
        [annotations addObject: marker];
        if ((finLat != 0) && (finLong != 0)){
            CLLocationCoordinate2D position2 = CLLocationCoordinate2DMake(finLat, finLong);
            MKPointAnnotation *marker2 = [[MKPointAnnotation alloc] init];
            marker2.coordinate = position2;
            marker2.title = [NSString stringWithFormat:@"%d",identifier];
            marker2.subtitle = [NSString stringWithFormat:@"%d",approved];
            [route setMarker:marker2];
            //[self.mapView addAnnotation:marker2];
            [annotations addObject:marker2];
        }
        [self.routes addObject:route];
        self.clusteringManager = [[FBClusteringManager alloc] initWithAnnotations:annotations];
        self.clusteringManager.delegate = self;
        [self mapView:self.mapView regionDidChangeAnimated:NO];
        //TODO center camera over tenerife
    }
    [results close];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
        NSArray *annotations = [self.clusteringManager clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];
        //NSLog([NSString stringWithFormat:@"scale %f", scale]);
    
        [self.clusteringManager displayAnnotations:annotations onMapView:mapView];
    }];
}

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
    
    if ([annotation isKindOfClass:[FBAnnotationCluster class]]){
                if (!pinView) {
                    FBAnnotationCluster *cluster = (FBAnnotationCluster *)annotation;
            cluster.title = [NSString stringWithFormat:@"%lu", (unsigned long)cluster.annotations.count];
            pinView = [[MKAnnotationView alloc] initWithAnnotation:cluster reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.image = [UIImage imageNamed:@"sol_icon"];
            pinView.canShowCallout = NO;

        }else{
            pinView.annotation = annotation;
            pinView.image = [UIImage imageNamed:@"sol_icon"];
            NSInteger i = 1;
            pinView.tag = i;
        }
        return pinView;
    }else
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]]){
        
        NSString *subtitle = [annotation subtitle];
        int type = [subtitle intValue];
        if (!pinView) {
            // If an existing pin view was not available, create one.
            
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            //pinView.animatesDrop = YES;
            pinView.canShowCallout = NO;
            pinView.centerOffset = CGPointMake(0, -pinView.image.size.height / 2);
            //pinView.calloutOffset = CGPointMake(0, 32);
            pinView.image = [self setIcon:type];
            
        } else {
            pinView.annotation = annotation;
            pinView.image = [self setIcon:type];
            NSInteger i = 0;
            pinView.tag = i;
        }
        return pinView;
    }
    return nil;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    renderer.strokeColor = [UIColor colorWithRed:204/255. green:45/255. blue:70/255. alpha:1.0];
    renderer.lineWidth = 3;
    
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
    CLLocationCoordinate2D pos = [[view annotation]coordinate];
    if (view.tag == 1) {
        NSLog(@"Hola");
        [self zoomInGesture:pos];
            //[self.mapView setCenterCoordinate:pos animated:YES];
    }else{
        NSString *title = [[view annotation] title];
        int identifier = [title intValue];
        Route *route = [self findRouteById:identifier];
        //CLLocationCoordinate2D pos = [[view annotation]coordinate];
        [self clickAction:route :pos];
        NSLog([NSString stringWithFormat:@"TAP: %@",route.getName]);
    }
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    if (view.tag == 0){
        NSString *title = [[view annotation] title];
        int identifier = [title intValue];
        Route *route = [self findRouteById:identifier];
        [self.mapView removeOverlays:self.mapView.overlays];
        NSLog([NSString stringWithFormat:@"Close %@ ",route.getName]);
    }else
    NSLog([NSString stringWithFormat:@"Deselect %ld",(long)view.tag]);
}
#pragma mark - FBClusterManager delegate - optional

- (CGFloat)cellSizeFactorForCoordinator:(FBClusteringManager *)coordinator
{
    return 0.6;
}

-(UIImage *)setIcon: (int)approved{
    
    UIImage *icon = nil;
    switch (approved) {
        case 0:
            icon = imageBrown;
            break;
        case 1:
            icon = imageGreen;
            break;
        case 2:
            icon = imageYellow;
            break;
        case 3:
            icon = imageRed;
            break;
        default:
            icon = imageBrown;
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
- (void)zoomInGesture: (CLLocationCoordinate2D)pos {
    MKCoordinateRegion region;// = self.mapView.region;
    region.center = pos;
    MKCoordinateSpan span = self.mapView.region.span;
    span.latitudeDelta *= 0.5;
    span.longitudeDelta *= 0.5;
    region.span = span;
    [self.mapView setRegion:region animated:YES];
}
@end
