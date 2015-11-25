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
#import "QuickInfoView.h"
#import "FBAnnotationClustering/FBAnnotationClustering.h"

#define METERS_PER_MILE 1609.344
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@interface ViewController : UIViewController <MKMapViewDelegate, FBClusteringManagerDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet QuickInfoView *quickInfoView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *panelWidth;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
- (IBAction)toggleList:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *pathList;
- (IBAction)deselect:(id)sender;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property Database *db;
@property NSMutableArray *routes;
@property (nonatomic, strong) CustomKMLParser *kmlParser;
@property (nonatomic, strong) FBClusteringManager *clusteringManager;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

