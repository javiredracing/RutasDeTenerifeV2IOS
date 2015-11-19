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


@interface ViewController ()


@end

@implementation ViewController

MKPolyline *polyLine;
UIImage *imageRed;
UIImage *imageYellow;
UIImage *imageGreen;
UIImage *imageBrown;
Route *lastRouteShowed;

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    self.locationManager = [[CLLocationManager alloc]init];
    self.mapView.showsUserLocation = YES;
    
    self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    self.mapView.delegate = self;
    self.db = [[Database alloc]init];
    imageBrown = [UIImage imageNamed:@"marker_sign_16_normal"];
    imageYellow = [UIImage imageNamed:@"marker_sign_16_yellow"];
    imageGreen = [UIImage imageNamed:@"marker_sign_16_green"];
    imageRed = [UIImage imageNamed:@"marker_sign_16_red"];
    [self gotoLocation];
    [self loadRoutes];
    
    //Gestures to sidepanel
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleList:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.pathList addGestureRecognizer:swipeRight];
    //TODO Get user location
    //http://ashishkakkad.com/2014/12/ios-8-map-kit-obj-c-get-users-location/
    // Do any additional setup after loading the view, typically from a nib.

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.locationManager != nil){
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
}

-(void)viewWillDisappear:(BOOL)animated{
    if (self.locationManager)
    {
       // self.mapView.showsUserLocation = NO;
        [self.locationManager stopUpdatingLocation];
    }
    [super viewWillDisappear:animated];
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
        return pinView;
    }else
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]]){
        
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
        return pinView;
    }
    return nil;
}


//Draw line with gradient https://github.com/wdanxna/GradientPolyline
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
    
    [mapView deselectAnnotation:view.annotation animated:YES];
    //MKAnnotation *annotation = [view annotation];
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

- (IBAction)deselect:(id)sender {
    
   }

/**Force didDeselectAnnotationView*/
/*-(void)closePath{
    NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
    for(id annotation in selectedAnnotations) {
        [self.mapView deselectAnnotation:annotation animated:NO];
    }
}*/

-(void)clickAction: (Route *)myroute: (CLLocationCoordinate2D)pos{
 
    if (lastRouteShowed != nil){
        if ([lastRouteShowed getId] == [myroute getId]){
            lastRouteShowed = nil;
        }
    }
    
    myroute.isActive = !myroute.isActive;
    if (lastRouteShowed != nil) {
        lastRouteShowed.isActive = NO;
    }
    lastRouteShowed = myroute;
    //if (polyLine != nil){
        [self.mapView removeOverlays:self.mapView.overlays];
    //}

    if (myroute.isActive){
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
        [self moveTo:pos];  //Center pos
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
    
    CTFontRef myFont = CTFontCreateWithName( (CFStringRef)@"Helvetica-Bold", 12.0f, NULL);
    
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
    return [self.routes count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PathCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if (!cell){
        [self.pathList registerNib:[UINib nibWithNibName:@"PathCell" bundle:nil] forCellReuseIdentifier:@"myCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    }
       return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(PathCellTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    Route *myRoute = [self.routes objectAtIndex:indexPath.row];
    cell.title.text = [myRoute getName];
    cell.distanceLabel.text = [NSString stringWithFormat:@"(%.1f km)",[myRoute getDist]];
    //NSUInteger dificult =
    cell.dificultImage.image = [self setDifficultIcon: [myRoute getDifficulty]];
    NSUInteger i = [myRoute getId];
    cell.tag = i;
}

/*- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 102.0;
}

#pragma mark - UITableView Delegate -
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    PathCellTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    NSUInteger identifier = cell.tag;
    Route *r = [self findRouteById:identifier];
    CLLocationCoordinate2D pos = [r getFirstPoint];
    [self clickAction:r :pos ];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - animations -

-(void)showRightList{
    //NSLog(@"ShowList");
    [UIView animateWithDuration:0.25 animations:^{
        CGRect originalFrame = [self currentScreenBoundsDependOnOrientation];
        [self.pathList setFrame:CGRectMake(originalFrame.size.width - 254, originalFrame.origin.y, 254, originalFrame.size.height)];
    }];
}

-(void)hideRightList{
    //NSLog(@"HideList");
    [UIView animateWithDuration:0.25 animations:^{
         CGRect originalFrame = [self currentScreenBoundsDependOnOrientation];
         [self.pathList setFrame:CGRectMake(originalFrame.size.width, originalFrame.origin.y, 0, originalFrame.size.height)];
    }];
}

-(CGRect)currentScreenBoundsDependOnOrientation
{
    
    CGRect screenBounds = [UIScreen mainScreen].bounds ;
    if(IS_OS_8_OR_LATER){
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
}

- (IBAction)toggleList:(id)sender {
    CGRect rect = self.pathList.frame;
    if (rect.size.width == 254){
        [self hideRightList];
    }else{
        [self showRightList];
    }
}
@end
