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

@interface ViewController ()


@end

@implementation ViewController{

MKPolyline *polyLine;
UIImage *imageRed;
UIImage *imageYellow;
UIImage *imageGreen;
UIImage *imageBrown;
Route *lastRouteShowed;
//CGRect panelRect;
BOOL onRouteMode;

NSMutableArray *filteredData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.locationManager = [[CLLocationManager alloc]init];
    self.mapView.showsUserLocation = YES;
    self.mapView.showsBuildings = NO;
     [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    onRouteMode = NO;
    
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
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deselect:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.pathList addGestureRecognizer:swipeRight];
    
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleList:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.menuList addGestureRecognizer:swipeLeft];
    
    //Tap over quickInfo View
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleQuickInfoTap:)];
    [self.quickInfoView addGestureRecognizer:singleFingerTap];
    
    //TODO Get user location
    //http://ashishkakkad.com/2014/12/ios-8-map-kit-obj-c-get-users-location/
    // Do any additional setup after loading the view, typically from a nib.
    
    //Hide views
    self.panelWidth.constant = 0;
    self.menuWidth.constant = 0;
    self.quickInfoView.alpha = 0.0;
    self.quickControl.alpha = 0.0;
    /*self.quickInfoView.layer.shadowColor = [[UIColor blackColor]CGColor];
    self.quickInfoView.layer.shadowOffset = CGSizeMake(0, 10);
    self.quickInfoView.layer.shadowRadius = 10;
    self.quickInfoView.layer.shadowOpacity = 0.5;*/
    self.quickInfoView.layer.borderColor = [UIColor redColor].CGColor;
    self.quickInfoView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.quickInfoView.layer.shadowOffset = CGSizeMake(12.0, 12.0);
    self.quickInfoView.layer.shadowOpacity = 0.8;
    self.quickInfoView.layer.shadowRadius = 0.0;
    [self hideQuickInfo];
    [self configureToast];
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
        [self showQuickInfo:myroute];
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
            NSUInteger i = [myRoute getId];
            cell.tag = i;
        }
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

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

#pragma mark - UITableView Delegate -
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (tableView.tag == 1){
        PathCellTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        NSUInteger identifier = cell.tag;
        Route *r = [self findRouteById:identifier];
        CLLocationCoordinate2D pos = [r getFirstPoint];
        [self clickAction:r :pos ];
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
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}
#pragma mark - animations -

-(void)showRightList{
    self.panelWidth.constant = 254;
    [UIView animateWithDuration:0.25 animations:^{
        [self.pathList layoutIfNeeded];
    }];
}

-(void)hideRightList{
    self.panelWidth.constant = 0;
    [UIView animateWithDuration:0.25 animations:^{
        [self.pathList layoutIfNeeded];
    }];
}
-(void)showLeftMenu{
    self.menuWidth.constant = 74;
    [UIView animateWithDuration:0.25 animations:^{
        [self.pathList layoutIfNeeded];
    }];
}

-(void)hideLeftMenu{
    self.menuWidth.constant = 0;
    [UIView animateWithDuration:0.25 animations:^{
        [self.pathList layoutIfNeeded];
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
        [UIView animateWithDuration:0.5 animations:^{
            self.quickInfoView.alpha = 1.0;
            self.quickControl.alpha = 1.0;
        }];
        
    }
}

-(void)hideQuickInfo{
    if (self.quickInfoView.hidden == NO){
        [UIView animateWithDuration:0.5 animations:^{
            self.quickInfoView.alpha = 0.0;
            self.quickControl.alpha = 0.0;
        }completion:^(BOOL finished) {
            [self disableOnRouteMode:self.quickControl];
            self.quickInfoView.hidden= YES;
            self.quickControl.hidden = YES;
            
        }];
    }
}

- (IBAction)toggleList:(id)sender {
    if (self.menuWidth.constant == 74){
        [self hideLeftMenu];
    }else{
        [self showLeftMenu];
    }
}
- (IBAction)deselect:(id)sender {
    if (self.panelWidth.constant == 254){
        [self hideRightList];
    }else{
        [self showRightList];
    }
}

- (void)handleQuickInfoTap:(UITapGestureRecognizer *)recognizer {
    //NSLog(@"HOLA!");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
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
            cell.icon.image = [UIImage imageNamed:@"close"];
            cell.iconTitle.text = @"Close";
            break;
        case 1:
            cell.icon.image = [UIImage imageNamed:@"icon_my_pos64"];
            cell.iconTitle.text = @"My pos";
            break;
        case 2:
            cell.icon.image = [UIImage imageNamed:@"map64"];
            cell.iconTitle.text = @"Map";
            break;
        case 3:
            cell.icon.image = [UIImage imageNamed:@"simple_filter_64"];
            cell.iconTitle.text = @"Filter";
            break;
        case 4:
            cell.icon.image = [UIImage imageNamed:@"info64"];
            cell.iconTitle.text = @"Info";
            break;
        case 5:
            cell.icon.image = [UIImage imageNamed:@"custom_share_64"];
            cell.iconTitle.text = @"Share";
            break;
        case 6:
            cell.icon.image = [UIImage imageNamed:@"unlock"];
            cell.iconTitle.text = @"Premium";
            break;
            
        default:
            break;
    }
}

-(void)actionMenu:(NSInteger)index{

    switch (index) {
        case 0: //Close
            [self toggleList:nil];
            break;
        case 1: //My pos
            
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
                    [self.view makeToast:address];
                }];
            }else{
                NSLog(@"Location no available");
                [self.view makeToast:@"Location no available"];
            }
            break;
        case 2: //Change map type
            if ([self.mapView mapType] == MKMapTypeSatellite) {
                [self.mapView setMapType: MKMapTypeHybrid];
                [self.view makeToast:@"Modo híbrido"];
            } else {
                if ([self.mapView mapType] == MKMapTypeHybrid) {
                    [self.mapView setMapType: MKMapTypeStandard];
                    [self.view makeToast:@"Modo standard"];
                } else {
                    [self.mapView setMapType: MKMapTypeSatellite];
                    [self.view makeToast:@"Modo satelite"];
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
            
            break;
        default:
            break;
    }
}

-(void)shareAction{
    UIImage *shareImage = [UIImage imageNamed:@"logo"];
    NSURL *shareUrl = [NSURL URLWithString:@"http://proyectoislarenovable.iter.es/el-juego/"];
    NSArray *activityItems = [NSArray arrayWithObjects:@"Rutas de Tenerife", shareImage, shareUrl, nil];
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
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
            if (polyLine != nil)
                [self.mapView setVisibleMapRect:[polyLine boundingMapRect] edgePadding:UIEdgeInsetsMake(20.0, 10.0, 20.0, 10.0) animated:YES];
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
    [self.view makeToast:@"Modo en ruta"];
    UIImage *imagePinned = [UIImage imageNamed:@"pinned_24"];
    //[[sender.subviews objectAtIndex:item] setTintColor:tintcolor];
    [control setImage:imagePinned forSegmentAtIndex:0];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}

-(void)disableOnRouteMode :(UISegmentedControl *)control{
    if (onRouteMode){
        onRouteMode = NO;
        UIImage *imagePinned = [UIImage imageNamed:@"pin_24"];
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
    style.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    style.messageAlignment = NSTextAlignmentCenter;
    style.messageColor = [UIColor grayColor];
    style.cornerRadius = 5.0;
    style.borderWidth = 2.0;
    style.borderColor =[[UIColor greenColor] colorWithAlphaComponent:0.8];
    [CSToastManager setSharedStyle:style];
    [CSToastManager setQueueEnabled:NO];
}

-(void)openAppInfo{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AppInfoNavViewController *navViewController = [storyboard instantiateViewControllerWithIdentifier:@"AppInfoNav"];
    [self presentViewController:navViewController animated:YES completion:nil];
}

-(void)launchFilter{
    //https://github.com/wimagguc/ios-custom-alertview
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createDemoView]];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancelar", @"Limpiar", @"Filtrar", nil]];
    //[alertView setDelegate:self];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        FilterView *filter = (FilterView *)[alertView containerView];
        switch (buttonIndex) {
            
            case 1:
                //Clear filter
                break;
            case 2:
                //apply filter
                break;
                
            default:
                //do nothing
                break;
        }
        NSLog([NSString stringWithFormat:@"%@ value: %f",filter.distanceLabel.text, filter.sliderDist.value]);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger i = (int)filter.sliderDist.value;
        [defaults setInteger:i forKey:@"distance"];
        //TODO
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
