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
#import "CustomIOSAlertView.h"
#import <Google/Analytics.h>

@import iAd;

#define METERS_PER_MILE 1609.344
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define outVerticalSpacing -60.0f
#define inVerticalSpacing 20.0f
#define outLeftPosition -75.0f
#define outRightPosition 255.0f

@interface ViewController : UIViewController <MKMapViewDelegate, FBClusteringManagerDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *listRightPosition;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuLeftPosition;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMainViewVerticalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quickControlVerticalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quickInfoVerticalSpace;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *quickControl;

@property (weak, nonatomic) IBOutlet QuickInfoView *quickInfoView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *pathList;
@property (weak, nonatomic) IBOutlet UITableView *menuList;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property Database *db;
@property NSMutableArray *routes;
@property (nonatomic, strong) CustomKMLParser *kmlParser;
@property (nonatomic, strong) FBClusteringManager *clusteringManager;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) ADBannerView *bannerView; //banner

- (IBAction)quickControlTap:(UISegmentedControl *)sender;
- (IBAction)toggleList:(id)sender;
- (IBAction)deselect:(id)sender;

@end

