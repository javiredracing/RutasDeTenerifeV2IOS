//
//  ExtendedInfoViewController.m
//  RutasDeTenerife2
//
//  Created by javi on 2/12/15.
//  Copyright © 2015 JAVI. All rights reserved.
//

#import "ExtendedInfoViewController.h"
//#import "RoundRectPresentationController.h"

@interface ExtendedInfoViewController ()

@end

@implementation ExtendedInfoViewController{
    
    UIDocumentInteractionController *docController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed:@"distance32"];
    
    [self.distance updateFields:NSLocalizedString(@"distance", @"") :[NSString stringWithFormat:@"%.1f km",[self.route getDist]] :image];
    [self.difficult updateFields:NSLocalizedString(@"difficulty", @"") :[self setDifficultText:[self.route getDifficulty]] :[self setDifficultIcon:[self.route getDifficulty]]];
    [self.time updateFields:NSLocalizedString(@"time", @"") :[NSString stringWithFormat:@"%.02f",[self.route getDurac]] :[UIImage imageNamed:@"timer"]];
    [self.approved updateFields:NSLocalizedString(@"aproved", @"") :[self setIsApproved:[self.route approved]] :[self setIcon:[self.route approved]]];
    UIColor *lightGreenColor = [UIColor colorWithRed:(187.0 / 255.0) green:(234.0 / 255.0) blue:(176.0 / 255.0) alpha:1.0];

    self.time.layer.borderColor = lightGreenColor.CGColor;
    self.difficult.layer.borderColor = lightGreenColor.CGColor;
    self.distance.layer.borderColor = lightGreenColor.CGColor;
    self.approved.layer.borderColor = lightGreenColor.CGColor;
    self.tvDecription.layer.borderColor = lightGreenColor.CGColor;
    self.btDownload.layer.borderColor = lightGreenColor.CGColor;
    self.btHowToGet.layer.borderColor = lightGreenColor.CGColor;
    self.tvDecription.textColor = [UIColor whiteColor];
    self.btHowToGet.layer.shadowColor = [UIColor grayColor].CGColor;
    self.btHowToGet.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.btHowToGet.layer.shadowOpacity = 0.8;
    self.btHowToGet.layer.shadowRadius = 5.0;
    
    self.btDownload.layer.shadowColor = [UIColor grayColor].CGColor;
    self.btDownload.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.btDownload.layer.shadowOpacity = 0.8;
    self.btDownload.layer.shadowRadius = 5.0;
    NSString *desc = [self.db getDescriptionById:[self.route getId] :@"es" ];
    [self.tvDecription setText:desc];
    
    UIColor *startGray = [UIColor colorWithRed:(204.0 / 255.0) green:(202.0 / 255.0) blue:(202.0 / 255.0) alpha:1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [self.view bounds];
    gradient.colors = [NSArray arrayWithObjects:(id)[startGray CGColor], (id)[[UIColor lightGrayColor] CGColor], nil];
    gradient.startPoint = CGPointZero;
    gradient.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidLayoutSubviews{
    //textview scroll start on top
    self.tvDecription.textColor = [UIColor whiteColor];
    [self.tvDecription setContentOffset:CGPointZero animated:NO];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}*/

- (IBAction)howToGet:(UIButton *)sender {
    CLLocationCoordinate2D endingCoord = [self.route getFirstPoint];
    MKPlacemark *endLocation = [[MKPlacemark alloc]initWithCoordinate:endingCoord addressDictionary:nil];
    MKMapItem *endingItem = [[MKMapItem alloc]initWithPlacemark:endLocation];
    
    NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
    [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
    [endingItem openInMapsWithLaunchOptions:launchOptions];
}
- (IBAction)downloadTrack:(UIButton *)sender {
    //TODO revise
    NSString *kmlName = [self.route getXmlRoute];
    kmlName =[kmlName substringToIndex:[kmlName length] - 4];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:kmlName ofType:@"gpx"];
    NSURL *url = [NSURL fileURLWithPath:path];
    //NSLog(path);
    if (!docController) {
        docController = [UIDocumentInteractionController interactionControllerWithURL:url];
        //http://stackoverflow.com/questions/31163785/trying-to-define-gpx-document-type-in-xcode-6-4
        //http://aplus.rs/2014/how-to-properly-share-slash-export-gpx-files-on-ios/
        docController.UTI = @"com.topografix.gpx";
        docController.delegate = self;
    }
    BOOL isCapable = [docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    if (!isCapable){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"app_name", @"") message:NSLocalizedString(@"no_gpx_installed", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    //[docController presentPreviewAnimated:YES];
}

-(UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self;
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

-(UIImage *)setIcon: (int)approved{

    UIImage *icon = nil;
    switch (approved) {
        case 0:
            icon = [UIImage imageNamed:@"marker_sign_24_normal"];
            break;
        case 1:
            icon = [UIImage imageNamed:@"marker_sign_24_green"];
            break;
        case 2:
            icon = [UIImage imageNamed:@"marker_sign_24_yellow"];
            break;
        case 3:
            icon = [UIImage imageNamed:@"marker_sign_24_red"];
            break;
        default:
            icon = [UIImage imageNamed:@"marker_sign_24_normal"];;
            break;
    }
    return icon;
}

-(NSString *)setIsApproved :(int)value{
    NSString * isApproved = NSLocalizedString(@"yes", @"");
    if (value == 0){
        isApproved = NSLocalizedString(@"no", @"");
    }
    return isApproved;
}

-(NSString *)setDifficultText :(int)value{
    NSString *text;
    switch (value) {
        case 1:
            text = NSLocalizedString(@"easy", @"");
            break;
        case 2:
            text = NSLocalizedString(@"moderate", @"");
            break;
        case 3:
            text = NSLocalizedString(@"difficult", @"");
            break;
        default:
            text = NSLocalizedString(@"moderate", @"");
            break;
    }
    return text;
}
@end
