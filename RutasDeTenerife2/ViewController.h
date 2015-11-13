//
//  ViewController.h
//  RutasDeTenerife2
//
//  Created by javi on 12/11/15.
//  Copyright © 2015 JAVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Database.h"
#import "Route.h"
#import "CustomKMLParser.h"

#define METERS_PER_MILE 1609.344

@interface ViewController : UIViewController <MKMapViewDelegate>
- (IBAction)deselect:(id)sender;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property Database *db;
@property NSMutableArray *routes;
@property (nonatomic, strong) CustomKMLParser *kmlParser;

@end

