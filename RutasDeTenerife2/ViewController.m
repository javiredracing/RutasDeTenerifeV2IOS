//
//  ViewController.m
//  RutasDeTenerife2
//
//  Created by javi on 12/11/15.
//  Copyright © 2015 JAVI. All rights reserved.
//

#import "ViewController.h"
#import "CoreText/CoreText.h"
#import "PathCellTableViewCell.h"
#import "MenuCell.h"
#import "ExtInfoNavViewController.h"
#import "AppInfoNavViewController.h"
#import "Toast/UIView+Toast.h"
#import "FilterView.h"
#import "GradientPolylineOverlay.h"
#import "GradientPolylineRenderer.h"


@interface ViewController ()

@end

@implementation ViewController{

//MKPolyline *polyLine;
GradientPolylineOverlay *polyLine;
UIImage *imageRed;
UIImage *imageYellow;
UIImage *imageGreen;
UIImage *imageBrown;
Route *lastRouteShowed;
//CGRect panelRect;
BOOL onRouteMode;
BOOL filterEnabled;
UIStoryboard *storyboard;

NSMutableArray *filteredData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.locationManager = [[CLLocationManager alloc]init];
    self.mapView.showsUserLocation = YES;
    self.mapView.showsBuildings = NO;
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    onRouteMode = NO;
    filterEnabled = NO;
    
    self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    self.mapView.delegate = self;
    self.db = [[Database alloc]init];
    imageBrown = [UIImage imageNamed:@"marker_sign_16_normal"];
    imageYellow = [UIImage imageNamed:@"marker_sign_16_yellow"];
    imageGreen = [UIImage imageNamed:@"marker_sign_16_green"];
    imageRed = [UIImage imageNamed:@"marker_sign_16_red"];
    
    self.menuButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.menuButton.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    self.menuButton.layer.shadowOpacity = 0.8;
    self.menuButton.layer.shadowRadius = 5.0;
    self.listButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.listButton.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    self.listButton.layer.shadowOpacity = 0.8;
    self.listButton.layer.shadowRadius = 5.0;
    
    [self gotoLocation];
    [self loadRoutes];
    
    //Gestures to sidepanel
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deselect:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.pathList addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleList:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.menuList addGestureRecognizer:swipeLeft];
    
    //Tap over quickInfo View
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleQuickInfoTap:)];
    [self.quickInfoView addGestureRecognizer:singleFingerTap];
    
    //TODO Get user location
    //http://ashishkakkad.com/2014/12/ios-8-map-kit-obj-c-get-users-location/
    // Do any additional setup after loading the view, typically from a nib.
    
    //Hide views
    self.panelWidth.constant = 0;
    self.menuWidth.constant = 0;
    //self.quickInfoView.alpha = 0.0;
    self.quickInfoVerticalSpace.constant = outVerticalSpacing;
    self.quickInfoView.hidden = YES;
    //[self.quickInfoView layoutIfNeeded];
    //self.quickControl.alpha = 0.0;
    /*self.quickInfoView.layer.shadowColor = [[UIColor blackColor]CGColor];
    self.quickInfoView.layer.shadowOffset = CGSizeMake(0, 10);
    self.quickInfoView.layer.shadowRadius = 10;
    self.quickInfoView.layer.shadowOpacity = 0.5;*/
    UIColor *lightGreenColor = Rgb2UIColor(187, 234, 176);
    self.quickInfoView.layer.borderColor = lightGreenColor.CGColor;
    self.quickInfoView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.quickInfoView.layer.shadowOffset = CGSizeMake(12.0, 12.0);
    self.quickInfoView.layer.shadowOpacity = 0.8;
    self.quickInfoView.layer.shadowRadius = 5.0;

    UIImage *imagePinned = [UIImage imageNamed:@"pin_24"];
    imagePinned = [imagePinned imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.quickControl setImage:imagePinned forSegmentAtIndex:0];
    
    UIImage *image2 = [UIImage imageNamed:@"center"];
    image2 = [image2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.quickControl setImage:image2 forSegmentAtIndex:1];
    
    UIImage *image3 = [UIImage imageNamed:@"CLOSE_24px_red"];
    image3 = [image3 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.quickControl setImage:image3 forSegmentAtIndex:2];
    
    //hideQuickControl
   
    self.quickControlVerticalSpace.constant = outVerticalSpacing;
     self.quickControl.hidden = YES;
    //self.quickControl.enabled = false;

    [self configureToast];
    
    /*Banner*/
    self.bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    self.bannerView.delegate = self;
    [self.view addSubview:self.bannerView];
    
}

-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    //[self.quickInfoView sizeToFit];
    if (self.locationManager != nil){
        if ([CLLocationManager locationServicesEnabled]){
            [self startTracking];
        }else{
            [self.quickControl setEnabled:NO forSegmentAtIndex:0];
        }
    }
    //Show Info on first launch
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasLaunched = [defaults boolForKey:@"hasLaunched"];
    if (!hasLaunched){
        [defaults setBool:YES forKey:@"hasLaunched"];
        [defaults synchronize];
        [self openAppInfo];
    }
    
    [self layoutAnimated:NO];//banner
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"main_map"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)viewWillDisappear:(BOOL)animated{
    if (self.locationManager)
    {
       // self.mapView.showsUserLocation = NO;
        [self.locationManager stopUpdatingLocation];
    }
    [super viewWillDisappear:animated];
}

-(void)viewDidLayoutSubviews{
    [self layoutAnimated:[UIView areAnimationsEnabled]];    //banner
}

/****** iAds protocol definitions *******/
-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    [self layoutAnimated:[UIView areAnimationsEnabled]];    //banner
}
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    [self layoutAnimated:[UIView areAnimationsEnabled]];    //banner
}
/*******************/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadRoutes{
    self.routes = [[NSMutableArray alloc]init];
    filteredData = [[NSMutableArray alloc]init];
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
        [filteredData addObject:route]; //Filtered data
        
        self.clusteringManager = [[FBClusteringManager alloc] initWithAnnotations:annotations];
        self.clusteringManager.delegate = self;
        //[self mapView:self.mapView regionDidChangeAnimated:NO];
    }
    [results close];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    //[self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
    //NSLog([NSString stringWithFormat:@"%f", userLocation.heading]);
    //userLocation.heading
    //CLHeading *heading = userLocation.heading;
    //heading.magneticHeading
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if ([CLLocationManager locationServicesEnabled])
        [self.quickControl setEnabled:YES forSegmentAtIndex:0];
    else{
        [self.quickControl setEnabled:NO forSegmentAtIndex:0];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
        NSArray *annotations = [self.clusteringManager clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];
        [self.clusteringManager displayAnnotations:annotations onMapView:mapView];
    }];
}

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
    
    if ([annotation isKindOfClass:[FBAnnotationCluster class]]){
         FBAnnotationCluster *cluster = (FBAnnotationCluster *)annotation;
        if (!pinView) {
            cluster.title = [NSString stringWithFormat:@"%lu", (unsigned long)cluster.annotations.count];
            pinView = [[MKAnnotationView alloc] initWithAnnotation:cluster reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.image = [self generateClusterIconWithCount:cluster.annotations.count];
            pinView.canShowCallout = NO;
            NSInteger i = 1;
            pinView.tag = i;
        }else{
            pinView.annotation = annotation;
            pinView.image = [self generateClusterIconWithCount:cluster.annotations.count];
            NSInteger i = 1;
            pinView.tag = i;
        }
        pinView.alpha = 1;
        return pinView;
    }else{
    
        if ([annotation isKindOfClass:[MKPointAnnotation class]]){
           
            BOOL isPointVisible = YES;
            //TODO if filterEnabled
            if (filterEnabled) {
                NSUInteger identifier = [[annotation title] integerValue];
                Route *route = [self findRouteById:identifier];
                isPointVisible = [route isVisible];
            }
            
            NSString *subtitle = [annotation subtitle];
            int type = [subtitle intValue];
            if (!pinView) {
                // If an existing pin view was not available, create one.
                pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
                pinView.canShowCallout = NO;
                pinView.centerOffset = CGPointMake(0, -pinView.image.size.height / 2);
                pinView.image = [self setIcon:type];
                NSInteger i = 0;
                pinView.tag = i;
            } else {
                pinView.annotation = annotation;
                pinView.image = [self setIcon:type];
                NSInteger i = 0;
                pinView.tag = i;
            }
            if (isPointVisible) {
                pinView.alpha = 1;
            }else{
                pinView.alpha = 0.4;
            }
            return pinView;
        }
    }
    return nil;
}


//Draw line with gradient https://github.com/wdanxna/GradientPolyline
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    
   /* MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    renderer.strokeColor = [UIColor colorWithRed:204/255. green:45/255. blue:70/255. alpha:1.0];
    renderer.lineWidth = 3;*/
    GradientPolylineRenderer *polylineRenderer = [[GradientPolylineRenderer alloc] initWithOverlay:overlay];
    polylineRenderer.lineWidth = 3.0f;
    return polylineRenderer;
}

/**
 Binary search by Identifier
 */
-(Route *)findRouteById: (NSUInteger)identifier{

    int min = 0, max = ((int)[self.routes count] - 1), mid=0;
    while (min <= max ) {
        mid = (min + max)/2;
        int currentVal = [[self.routes objectAtIndex:mid] getId];
        if (currentVal == identifier){
            break;
        }
        else
            if (identifier > currentVal){
                min = mid+1;
            }else{
                max = mid-1;
            }
    }
    return [self.routes objectAtIndex:mid];
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    [mapView deselectAnnotation:view.annotation animated:YES];
    //MKAnnotation *annotation = [view annotation];
    
      if ([view.annotation isKindOfClass:[MKUserLocation class]]){
          [self showMypPosInformation];
      }else{
            CLLocationCoordinate2D pos = [[view annotation]coordinate];
            if (view.tag == 1) {
                //NSLog(@"Hola");
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
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    /*if (view.tag == 0){
        NSString *title = [[view annotation] title];
        int identifier = [title intValue];
        Route *route = [self findRouteById:identifier];
        [self.mapView removeOverlays:self.mapView.overlays];
        NSLog([NSString stringWithFormat:@"Close %@ ",route.getName]);
    }else
    NSLog([NSString stringWithFormat:@"Deselect %ld",(long)view.tag]);*/
}

#pragma mark - FBClusterManager delegate - optional

- (CGFloat)cellSizeFactorForCoordinator:(FBClusteringManager *)coordinator
{
    return 1;
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

-(UIImage *)setDifficultIcon: (int)difficult{

    UIImage *image = nil;
    switch (difficult) {
        case 1:
            image = [UIImage imageNamed:@"nivel_facil"];
            break;
        case 2:
            image = [UIImage imageNamed:@"nivel_intermedio"];
            break;
        case 3:
            image = [UIImage imageNamed:@"nivel_dificil"];
            break;
        default:
            image = [UIImage imageNamed:@"nivel_intermedio"];
            break;
    }
    return image;
}



/**Force didDeselectAnnotationView*/
/*-(void)closePath{
    NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
    for(id annotation in selectedAnnotations) {
        [self.mapView deselectAnnotation:annotation animated:NO];
    }
}*/

-(void)clickAction: (Route *)myCurrentRoute :(CLLocationCoordinate2D)pos{
 
    if (lastRouteShowed != nil){
        if ([lastRouteShowed getId] == [myCurrentRoute getId]){
            lastRouteShowed = nil;
        }
    }
    
    myCurrentRoute.isActive = !myCurrentRoute.isActive;
    if (lastRouteShowed != nil) {
        lastRouteShowed.isActive = NO;
    }
    lastRouteShowed = myCurrentRoute;
    //if (polyLine != nil){
        [self.mapView removeOverlays:self.mapView.overlays];
    //}

    if (myCurrentRoute.isActive){
        NSString *kmlName = [myCurrentRoute getXmlRoute];
        kmlName =[kmlName substringToIndex:[kmlName length] - 4];
        NSLog(kmlName);
        
        NSString *path = [[NSBundle mainBundle] pathForResource:kmlName ofType:@"kml"];
        NSURL *url = [NSURL fileURLWithPath:path];
        int identifier = [myCurrentRoute getId];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            //code to be executed in the background
            if ((self.kmlParser == nil) || (self.kmlParser.identifier != identifier)){  //Check if cached previously
                self.kmlParser = [[CustomKMLParser alloc] initWithURL:url identifier:identifier];
                [self.kmlParser parseKML];
                
            }/*else
                NSLog(@"id:%d cached",self.kmlParser.identifier);*/
            
            NSMutableArray *coordinates = self.kmlParser.path;
            NSMutableArray *altitude = self.kmlParser.altitude;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //code to be executed on the main thread when background task is finished
                NSUInteger size = [coordinates count];
                CLLocationCoordinate2D stepCoordinates[size];
                float stepAltitude[size];
                
                for (NSUInteger i = 0; i < size; i++){
                    NSValue *value = [coordinates objectAtIndex:i];
                    CLLocationCoordinate2D c = [value MKCoordinateValue];
                    stepCoordinates[i] = c;
                    
                    stepAltitude[i] = [[altitude objectAtIndex:i] floatValue];
                }
                //polyLine = [MKPolyline polylineWithCoordinates:stepCoordinates count:size];
                polyLine = [[GradientPolylineOverlay alloc] initWithPoints:stepCoordinates velocity:stepAltitude  count:size];
                [self.mapView addOverlay:polyLine];
                });
            });
        [self showQuickInfo:myCurrentRoute];
        [self moveTo:pos];  //Center pos
    }else{
        [self hideQuickInfo];
    }
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

- (void)moveTo: (CLLocationCoordinate2D)pos {
    MKCoordinateRegion region;// = self.mapView.region;
    region.center = pos;
    if (self.mapView.region.span.latitudeDelta > 0.5) {
        region.span.latitudeDelta = 0.5;
        region.span.longitudeDelta = 0.5;
    }else
        region.span = self.mapView.region.span;
    
    [self.mapView setRegion:region animated:YES];
}


- (void)gotoLocation{
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(28.25600562, -16.52069092);
    MKCoordinateSpan span = MKCoordinateSpanMake(1.3, 1.3);
    MKCoordinateRegion regionToDisplay = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion:regionToDisplay];
}

- (UIImage*)generateClusterIconWithCount:(NSUInteger)count {
    
    int diameter = 30;
    float inset = 2;
    
    CGRect rect = CGRectMake(0, 0, diameter, diameter);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // set stroking color and draw circle
    [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8] setStroke];
    
    if (count > 100) [[UIColor orangeColor] setFill];
    else if (count > 10) [[UIColor yellowColor] setFill];
    else [[UIColor colorWithRed:0.0/255.0 green:100.0/255.0 blue:255.0/255.0 alpha:1] setFill];
    
    CGContextSetLineWidth(ctx, inset);
    
    // make circle rect 5 px from border
    CGRect circleRect = CGRectMake(0, 0, diameter, diameter);
    circleRect = CGRectInset(circleRect, inset, inset);
    
    // draw circle
    CGContextFillEllipseInRect(ctx, circleRect);
    CGContextStrokeEllipseInRect(ctx, circleRect);
    
    CTFontRef myFont = CTFontCreateWithName( (CFStringRef)@"HelveticaNeue-Bold", 12.0f, NULL);
    
    UIColor *fontColor;
    if ((count < 100) && count > 10) fontColor = [UIColor blackColor];
    else fontColor = [UIColor whiteColor];
    
    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (__bridge id)myFont, (id)kCTFontAttributeName,
                                    fontColor, (id)kCTForegroundColorAttributeName, nil];
    
    // create a naked string
    NSString *string = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)count];
    
    NSAttributedString *stringToDraw = [[NSAttributedString alloc] initWithString:string
                                                                       attributes:attributesDict];
    
    // flip the coordinate system
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, diameter);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(stringToDraw));
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
                                                                        frameSetter, /* Framesetter */
                                                                        CFRangeMake(0, stringToDraw.length), /* String range (entire string) */
                                                                        NULL, /* Frame attributes */
                                                                        CGSizeMake(diameter, diameter), /* Constraints (CGFLOAT_MAX indicates unconstrained) */
                                                                        NULL /* Gives the range of string that fits into the constraints, doesn't matter in your situation */
                                                                        );
    CFRelease(frameSetter);
    
    //Get the position on the y axis
    float midHeight = diameter;
    midHeight -= suggestedSize.height;
    
    float midWidth = diameter / 2;
    midWidth -= suggestedSize.width / 2;
    
    CTLineRef line = CTLineCreateWithAttributedString(
                                                      (__bridge CFAttributedStringRef)stringToDraw);
    CGContextSetTextPosition(ctx, midWidth, 12);
    CTLineDraw(line, ctx);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


/************** TableView *****************/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //NSLog([NSString stringWithFormat:@"numbers of row %lu", (unsigned long)self.routes.count]);
    NSInteger count = 0;
    if (tableView.tag == 1){
        NSUInteger tam = [filteredData count];
        for (NSUInteger i = 0; i < tam; i++) {
            Route *route = [filteredData objectAtIndex:i];
            if ([route getRegion] == section) {
                count++;
            }
        }
    }else{
        count = 7;
    }
    return count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger count = 1;
    if (tableView.tag == 1)
        count = 6;
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 0) {
        MenuCell *cell = (MenuCell *)[tableView dequeueReusableCellWithIdentifier:@"menuCell"];
        if (!cell){
            /*[self.menuList registerNib:[UINib nibWithNibName:@"MenuCell" bundle:nil] forCellReuseIdentifier:@"menuCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
            return cell;*/
            NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:self options:nil];
            cell = [nibArray objectAtIndex:0];
        }
        return cell;
    }else{
        PathCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
        if (!cell){
            [self.pathList registerNib:[UINib nibWithNibName:@"PathCell" bundle:nil] forCellReuseIdentifier:@"myCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
        }
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    if (tableView.tag == 0) {
        MenuCell *newCell = (MenuCell *)cell;
        
        [self fillMenuCell:newCell :indexPath.row];
    }else{
        NSUInteger counter = 0;
        Route *myRoute = nil;
        NSUInteger size = [filteredData count];
        for (NSUInteger i = 0; i < size; i++) {
             myRoute = [filteredData objectAtIndex:i];
            if ([myRoute getRegion] == indexPath.section){
                if (counter == indexPath.row) {
                    break;
                }else
                    counter++;
            }
        }

        if (myRoute != nil) {
            PathCellTableViewCell *newCell = (PathCellTableViewCell *)cell;
            newCell.title.text = [myRoute getName];
            newCell.distanceLabel.text = [NSString stringWithFormat:@"(%.1f km)",[myRoute getDist]];
            //NSUInteger dificult =
            newCell.dificultImage.image = [self setDifficultIcon: [myRoute getDifficulty]];
           /* if (myRoute.isVisible) {
                newCell.alpha = 1;
            }else
                newCell.alpha = 0.4;*/
            NSUInteger i = [myRoute getId];
            cell.tag = i;
        }
    }
}

/*-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    NSString *regionName = nil;
    if (tableView.tag == 1){
        switch (section){
            case 0:
                regionName = @"P. R. Anaga";
                break;
            case 1:
                regionName = @"Zona Norte";
                break;
            case 2:
                regionName = @"P. R. Teno";
                break;
            case 3:
                regionName = @"Zona Sur";
                break;
            case 4:
                regionName = @"P. N. Teide";
                break;
            case 5:
                regionName = @"GR-131";
                break;
            default:
                regionName= @"no region";
        }
    }
    return regionName;
}*/

-(NSString *)stringTitleForSection :(NSInteger) section{
    NSString *regionName = @"";
    switch (section){
        case 0:
            regionName = @"P. R. Anaga";
            break;
        case 1:
            regionName = NSLocalizedString(@"north_zone", @"");
            break;
        case 2:
            regionName = @"P. R. Teno";
            break;
        case 3:
            regionName = NSLocalizedString(@"south_zone", @"");
            break;
        case 4:
            regionName = @"P. N. Teide";
            break;
        case 5:
            regionName = @"GR-131";
            break;
        default:
            regionName= @"no region";
    }
    return regionName;

}

/*- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 94.0f;
    if (tableView.tag == 1) {
        height = 102.0f;
    }
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
        /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, tableView.frame.size.width, 18)];
    label.textAlignment = NSTextAlignmentCenter;

    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16]];
    label.textColor = [UIColor whiteColor];
    NSString *string;
    if (tableView.tag == 1){
        string =[self stringTitleForSection:section];
    }else
        string = NSLocalizedString(@"menu", @"");
;
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor grayColor]]; //your background color...
    return view;
}

#pragma mark - UITableView Delegate -
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (tableView.tag == 1){
        PathCellTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        NSUInteger identifier = cell.tag;
        Route *r = [self findRouteById:identifier];
        CLLocationCoordinate2D pos = [r getFirstPoint];
        [self clickAction:r :pos];
        [self hideRightList];   //Close panel
    }else{
        [self actionMenu:indexPath.row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    //NSLog(searchText);
    if([searchText isEqualToString:@""] || searchText==nil) {
        filteredData = [[NSMutableArray alloc]initWithArray:self.routes];
        [self.searchBar resignFirstResponder];
    }else{
        filteredData = [[NSMutableArray alloc] init];
        for (Route *route in self.routes) {
            NSRange nameRange = [[route getName]rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (nameRange.location != NSNotFound) {
                [filteredData addObject:route];
            }
        }
    }
    [self.pathList reloadData];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //NSLog(@"cancel button");
    [self.searchBar resignFirstResponder];
    if (![searchBar.text isEqualToString:@""]){
        searchBar.text = @"";
        filteredData = [[NSMutableArray alloc]initWithArray:self.routes];
        [self.pathList reloadData];
    }else{
    //TODO clear texview
        [self hideRightList];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}
#pragma mark - animations -

-(void)showRightList{
    self.panelWidth.constant = 255;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.pathList layoutIfNeeded];
           }completion:^(BOOL finished){
        //Do nothing
    }];
}

-(void)hideRightList{
    self.panelWidth.constant = 0;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.pathList layoutIfNeeded];
    }completion:^(BOOL finished){
        //Do nothing
    }];
}
-(void)showLeftMenu{
    self.menuWidth.constant = 75;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
         [self.menuList layoutIfNeeded];
    }completion:^(BOOL finished){
        //Do nothing
    }];
}

-(void)hideLeftMenu{
    self.menuWidth.constant = 0;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.menuList layoutIfNeeded];
    }completion:^(BOOL finished){
        //Do nothing
    }];

}

/*-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"Scrolling");
    CGRect rect = self.searchBar.frame;
    rect.origin.y = MIN(0, scrollView.contentOffset.y);
    self.searchBar.frame = rect;
}*/
/*-(CGRect)currentScreenBoundsDependOnOrientation
{
    
    CGRect screenBounds = [UIScreen mainScreen].bounds ;
    if(IS_OS_8_OR_LATER){
    
        NSLog([NSString stringWithFormat:@"Size screen %@", NSStringFromCGRect(screenBounds)]);
        return screenBounds ;
    }
    CGFloat width = CGRectGetWidth(screenBounds)  ;
    CGFloat height = CGRectGetHeight(screenBounds) ;
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        screenBounds.size = CGSizeMake(width, height);
    }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        screenBounds.size = CGSizeMake(height, width);
    }
    return screenBounds ;
}*/

-(void)showQuickInfo: (Route *)myroute{
        [self.quickInfoView changeContent:[myroute getName] :[myroute getDist] :[myroute getDifficulty] :[myroute approved]];
    if (self.quickInfoView.hidden == YES){
        self.quickInfoView.hidden= NO;
        self.quickControl.hidden = NO;
        self.quickInfoVerticalSpace.constant = inVerticalSpacing;
        self.quickControlVerticalSpace.constant = inVerticalSpacing;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.containerView layoutIfNeeded];
        }completion:^(BOOL finished){
           //Do nothing
        }];
    }
}

-(void)hideQuickInfo{
    if (self.quickInfoView.hidden == NO){
        self.quickInfoVerticalSpace.constant = outVerticalSpacing;
        self.quickControlVerticalSpace.constant = outVerticalSpacing;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.containerView layoutIfNeeded];
        }completion:^(BOOL finished){
            self.quickInfoView.hidden= YES;
            self.quickControl.hidden = YES;
        }];
    }
}

- (IBAction)toggleList:(id)sender {
    if (self.menuWidth.constant == 75){
        [self hideLeftMenu];
    }else{
        [self showLeftMenu];
    }
}
- (IBAction)deselect:(id)sender {
    if (self.panelWidth.constant == 255){
        [self hideRightList];
    }else{
        [self showRightList];
    }
}

- (void)handleQuickInfoTap:(UITapGestureRecognizer *)recognizer {
    //NSLog(@"HOLA!");
    if (storyboard == nil)
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ExtInfoNavViewController *extendedInfoVC = [storyboard instantiateViewControllerWithIdentifier:@"ExtendedInfoNav"];
    //ExtendedInfoViewController *extendedInfoVC =[storyboard instantiateViewControllerWithIdentifier:@"ExtendedInfo"];
    extendedInfoVC.route = lastRouteShowed;
    if (self.kmlParser != NULL)
        extendedInfoVC.altitude = self.kmlParser.altitude;
    extendedInfoVC.db = self.db;
    [self presentViewController:extendedInfoVC animated:YES completion:nil];
}

-(void)fillMenuCell :(MenuCell *)cell :(NSInteger)index{
    switch (index) {
        case 0:
            cell.icon.image = [UIImage imageNamed:@"CLOSE_64px_red"];
            cell.iconTitle.text =[NSString stringWithFormat:NSLocalizedString(@"close", @"")];
            break;
        case 1:
            cell.icon.image = [UIImage imageNamed:@"icon_my_pos64"];
            cell.iconTitle.text = [NSString stringWithFormat:NSLocalizedString(@"my_pos", @"")];
            break;
        case 2:
            cell.icon.image = [UIImage imageNamed:@"map64"];
            cell.iconTitle.text = [NSString stringWithFormat:NSLocalizedString(@"map", @"")];
            break;
        case 3:
            cell.icon.image = [UIImage imageNamed:@"simple_filter_64"];
            cell.iconTitle.text = [NSString stringWithFormat:NSLocalizedString(@"filter", @"")];
            break;
        case 4:
            cell.icon.image = [UIImage imageNamed:@"info64"];
            cell.iconTitle.text = [NSString stringWithFormat:NSLocalizedString(@"info", @"")];
            break;
        case 5:
            cell.icon.image = [UIImage imageNamed:@"custom_share_64"];
            cell.iconTitle.text = [NSString stringWithFormat:NSLocalizedString(@"share", @"")];
            break;
        case 6:
            cell.icon.image = [UIImage imageNamed:@"unlock"];
            cell.iconTitle.text = [NSString stringWithFormat:NSLocalizedString(@"premium", @"")];
            break;
            
        default:
            break;
    }
}

-(void)actionMenu:(NSInteger)index{

    switch (index) {
        /*case 0: //Close
            [self toggleList:nil];
            break;*/
        case 1: //My pos
            [self showMypPosInformation];
            break;
        case 2: //Change map type
            if ([self.mapView mapType] == MKMapTypeSatellite) {
                [self.mapView setMapType: MKMapTypeHybrid];
                [self.containerView makeToast:NSLocalizedString(@"hibrid", @"")];
            } else {
                if ([self.mapView mapType] == MKMapTypeHybrid) {
                    [self.mapView setMapType: MKMapTypeStandard];
                    [self.containerView makeToast:NSLocalizedString(@"standard", @"")];
                } else {
                    [self.mapView setMapType: MKMapTypeSatellite];
                    [self.containerView makeToast:NSLocalizedString(@"satellite", @"")];
                }
            }
            break;
        case 3: //Filter
            [self launchFilter];
            break;
        case 4: //Info
            [self openAppInfo];
            break;
        case 5: //share
            [self shareAction];
            break;
        case 6: //premium
            [self showPremiumDialog];
            break;
        default:
            break;
    }
    [self toggleList:nil];
}

-(void)shareAction{
    UIImage *shareImage = [UIImage imageNamed:@"logo"];
    NSURL *shareUrl = [NSURL URLWithString:NSLocalizedString(@"share_text", @"")];
    NSArray *activityItems = [NSArray arrayWithObjects:[NSString stringWithFormat:NSLocalizedString(@"app_name", @"")], shareImage, shareUrl, nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToVimeo, UIActivityTypePostToFlickr, /*UIActivityTypeAssignToContact, */UIActivityTypeAddToReadingList];
    //-- define the activity view completion handler
    //activityViewController.completionHandler = ^(NSString *activityType, BOOL completed){
   /* activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //UIAlertViewQuick(@"Activity Status", activityType, @"OK");
            NSLog(@"send");
        });
        if (completed){
            NSLog(@"The Activity: %@ was completed", activityType);
        }else{
            NSLog(@"The Activity: %@ was NOT completed", activityType);
        }
      };*/
    //if iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    //if iPad
    else {
        // Change Rect to position Popover
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        [popup presentPopoverFromRect:CGRectMake(self.containerView.frame.size.width/2, self.containerView.frame.size.height/4, 0, 0)inView:self.containerView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
   // [self presentViewController:activityViewController animated:YES completion:nil];
}

- (IBAction)quickControlTap:(UISegmentedControl *)sender {
   // NSLog(@"tap control %ld",(long)sender.selectedSegmentIndex);
    switch (sender.selectedSegmentIndex) {
        case 0:
             if (!onRouteMode) {
                 [self enableOnRouteMode:sender];
            } else {
                [self disableOnRouteMode:sender];
            }
            break;
        case 1:
            if (polyLine != nil){
                MKPolygon *polygon = [MKPolygon polygonWithPoints:polyLine.points count:polyLine.pointCount];
                [self.mapView setVisibleMapRect:[polygon boundingMapRect] edgePadding:UIEdgeInsetsMake(20.0, 10.0, 20.0, 10.0) animated:YES];
            }
            break;
        case 2:
            if (lastRouteShowed != nil)
                [self clickAction:lastRouteShowed :[lastRouteShowed getFirstPoint]];
            break;
            
        default:
            break;
    }
}

-(void)enableOnRouteMode :(UISegmentedControl *)control{
    onRouteMode = YES;
    //UIColor *tintcolor = [UIColor greenColor];
    [self.containerView makeToast:[NSString stringWithFormat:NSLocalizedString(@"on_route", @"")] duration:2.0 position:CSToastPositionCenter];
    UIImage *imagePinned = [UIImage imageNamed:@"pinned_24"];
    imagePinned = [imagePinned imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //[[sender.subviews objectAtIndex:item] setTintColor:tintcolor];
    [control setImage:imagePinned forSegmentAtIndex:0];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}

-(void)disableOnRouteMode :(UISegmentedControl *)control{
    if (onRouteMode){
        onRouteMode = NO;
        UIImage *imagePinned = [UIImage imageNamed:@"pin_24"];
        imagePinned = [imagePinned imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        //[[control.subviews objectAtIndex:item] setTintColor:control.tintColor];
        [control setImage:imagePinned forSegmentAtIndex:0];
        [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    }
}

-(void)startTracking{
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        // Use one or the other, not both. Depending on what you put in info.plist
        [self.locationManager requestWhenInUseAuthorization];
        //[self.locationManager requestAlwaysAuthorization];
    }
#endif
    NSLog(@"start updating");
    [self.locationManager startUpdatingLocation];
    
    if ([CLLocationManager headingAvailable]) {
        NSLog(@"Heading available");
        self.locationManager.headingFilter = 5;
        [self.locationManager startUpdatingHeading];
    }
}

-(void)configureToast{
    //https://github.com/scalessec/Toast
    CSToastStyle *style = [[CSToastStyle alloc]initWithDefaultStyle];
    style.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    style.messageAlignment = NSTextAlignmentCenter;
    style.messageColor = [UIColor lightGrayColor];
    style.cornerRadius = 5.0;
    style.borderWidth = 2.0;
    style.borderColor =[Rgb2UIColor(187, 234, 176) colorWithAlphaComponent:0.9];
    [CSToastManager setSharedStyle:style];
    [CSToastManager setQueueEnabled:NO];
}

-(void)openAppInfo{
    if (storyboard == nil)
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AppInfoNavViewController *navViewController = [storyboard instantiateViewControllerWithIdentifier:@"AppInfoNav"];

    [self presentViewController:navViewController animated:YES completion:nil];
}

-(void)launchFilter{
    //https://github.com/wimagguc/ios-custom-alertview
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createDemoView]];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:NSLocalizedString(@"cancel", @"")], [NSString stringWithFormat:NSLocalizedString(@"clean", @"")], [NSString stringWithFormat:NSLocalizedString(@"filter", @"")], nil]];
    //[alertView setDelegate:self];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        //NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        FilterView *filter = (FilterView *)[alertView containerView];
        NSInteger dist = 0;
        NSInteger dif = 0;
        NSInteger durac = 0;
        NSUInteger size = [self.routes count];
        switch (buttonIndex) {
            
            case 1:
                //Clear filter, all markers Visible
                filterEnabled = NO;
                [self saveFilterDefaults:dist :dif :durac];
               
                for (NSUInteger i = 0; i < size; i++) {
                    [[self.routes objectAtIndex:i] setMarkerVisibilityTrue];
                }
                [self redrawMarkersAndCusters:self.mapView];
                break;
            case 2:
                dist = (int)filter.sliderDist.value;
                dif = (int)filter.sliderDific.value;
                durac = (int)filter.sliderDurac.value;
                if ((dist == 0) && (dif == 0) && (durac == 0)) {
                    filterEnabled = NO;
                }else
                    filterEnabled = YES;
                
                [self saveFilterDefaults:dist :dif :durac];
                for (NSUInteger i = 0; i < size; i++) {
                    [[self.routes objectAtIndex:i] setMarkersVisibility:dist :dif :durac];
                }
                //apply filter
                [self redrawMarkersAndCusters:self.mapView];
                break;
                
            default:
                //do nothing
                break;
        }
        //NSLog([NSString stringWithFormat:@"%@ value: %f",filter.distanceLabel.text, filter.sliderDist.value]);
        [alertView close];
    }];
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];
}

- (UIView *)createDemoView
{
   // UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
    FilterView *filter = [[FilterView alloc] initWithFrame:CGRectMake(0, 0, 290, 250)];
    return filter;
}

-(void)saveFilterDefaults: (NSInteger)dist : (NSInteger)dif :(NSInteger)durac{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:dist forKey:@"distance"];
    [defaults setInteger:dif forKey:@"dific"];
    [defaults setInteger:durac forKey:@"durac"];
    [defaults synchronize];
}

//TODO revise
-(void)redrawMarkersAndCusters :(MKMapView *)mapView{
    for (id<MKAnnotation> annotation in mapView.annotations){
        if ([annotation isKindOfClass:[MKPointAnnotation class]]){
            
            BOOL isPointVisible = YES;
            //TODO if filterEnabled
            NSUInteger identifier = [[annotation title] integerValue];
            Route *route = [self findRouteById:identifier];
            isPointVisible = [route isVisible];
            //NSLog([NSString stringWithFormat:@"Name: %@, dist:%.1f, dif:%d, durac:%.1f visible:%@",route.getName, route.getDist, route.getDifficulty, route.getDurac, route.isVisible ? @"YES" : @"NO"]);
            MKAnnotationView* anView = [mapView viewForAnnotation: annotation];
            if (anView){
                if (isPointVisible) {
                    anView.alpha = 1;
                }else{
                    anView.alpha = 0.4;
                }
            }
        }
    }
}

-(void)showPremiumDialog{

    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    //TODO add internal margins to uilabel
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 290, 200)];
    
    UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 270, 200)];
    /* UIEdgeInsets myLabelInsets = {0,20,0,20};
    [lbl1 drawTextInRect:UIEdgeInsetsInsetRect(lbl1.frame, myLabelInsets)];*/
    lbl1.textColor = [UIColor grayColor];
    lbl1.backgroundColor = [UIColor clearColor];
    lbl1.userInteractionEnabled = NO;
    lbl1.numberOfLines = 0;
    lbl1.clipsToBounds = YES;
    lbl1.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    lbl1.text = NSLocalizedString(@"help_me", @"");
    //[lbl1 sizeToFit];
    lbl1.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
   
    [view addSubview:lbl1];
    [alertView setContainerView:view];
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"cancel", @""), NSLocalizedString(@"collaborate", @""), nil, nil]];

    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        [alertView close];
    }];
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];

}

-(void)showMypPosInformation{
    if (self.locationManager.location != nil){
        CLLocationCoordinate2D loc = [self.locationManager.location coordinate];
        [self moveTo:loc];
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        [geocoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error){
            NSString *address;
            if (error) {
                address = [NSString stringWithFormat:@"(%f, %f)",loc.latitude, loc.longitude];
            }else{
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                address = [NSString stringWithFormat:@"%@, %@, %@, %@, %@", placemark.thoroughfare, placemark.subLocality ,placemark.locality, placemark.subAdministrativeArea, placemark.administrativeArea];
            }
            if (self.locationManager.location.altitude != NAN){
                address = [NSString stringWithFormat:@"%@ \r%@: %.0f m",address, NSLocalizedString(@"elevation", @""),self.locationManager.location.altitude];
            }
            [self.containerView makeToast:address];
        }];
    }else{
        NSLog(@"Location no available");
        [self.containerView makeToast:[NSString stringWithFormat:NSLocalizedString(@"no_location", @"")]];
    }


}

-(void)layoutAnimated:(BOOL)animated {
    CGRect contentFrame = self.view.bounds;
    
    // all we need to do is ask the banner for a size that fits into the layout area we are using
    CGSize sizeForBanner = [self.bannerView sizeThatFits:contentFrame.size];
    
    // compute the ad banner frame
    CGRect bannerFrame = self.bannerView.frame;
    
    if (self.bannerView.bannerLoaded) {
        
        // bring the ad into view
        contentFrame.size.height -= sizeForBanner.height;   // shrink down content frame to fit the banner below it
        bannerFrame.origin.y = contentFrame.size.height;
        bannerFrame.size.height = sizeForBanner.height;
        bannerFrame.size.width = sizeForBanner.width;
        
        NSLayoutConstraint *verticalBottomConstraint = self.bottomMainViewVerticalSpace;
        verticalBottomConstraint.constant = sizeForBanner.height;
        [self.view layoutSubviews];
        
    }else {
        // hide the banner off screen further off the bottom
        bannerFrame.origin.y = contentFrame.size.height;
    }
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
        self.bannerView.frame = bannerFrame;
    }completion:^(BOOL finished){
        //Do nothing
    }];
}
/*- (void)listSubviewsOfView:(UIView *)view {
 
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
 
    // Return if there are no subviews
    if ([subviews count] == 0) return; // COUNT CHECK LINE
    
    for (UIView *subview in subviews) {
        
        // Do what you want to do with the subview
        NSLog(@"%@", subview);
        
        // List the subviews of subview
        [self listSubviewsOfView:subview];
    }
}*/


@end
