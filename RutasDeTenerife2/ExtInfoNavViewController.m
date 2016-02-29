//
//  ExtInfoNavViewController.m
//  RutasDeTenerife2
//
//  Created by javi on 4/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "ExtInfoNavViewController.h"
#import "RoundRectPresentationController.h"
#import "ExtendedInfoTabViewController.h"


//#define FONT_SIZE_DEFAULT  25

@interface ExtInfoNavViewController ()<UIViewControllerTransitioningDelegate>
@end
//https://github.com/bricklife/PresentationControllerSample
@implementation ExtInfoNavViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([self respondsToSelector:@selector(setTransitioningDelegate:)]){
            self.modalPresentationStyle = UIModalPresentationCustom;
            self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            self.transitioningDelegate = self;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create a custom `titleLabel`.
    /*UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320-10, 44)];
    titleLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:[UIFont fontNamesForFamilyName:[UIFont familyNames][0]][0] size:FONT_SIZE_DEFAULT];
    titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    titleLabel.text = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] lowercaseString]; // Fontful
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];*/
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:0];
    [label setTextColor:[UIColor whiteColor]];
    label.textAlignment = NSTextAlignmentCenter;
    //self.navigationItem.titleView = label;
    [label setText:self.route.getName];
    self.navigationBar.topItem.titleView = label;
   // NSLog(@"NavController loaded");
    NSArray *viewControllers = [self viewControllers];
    ExtendedInfoTabViewController *tabViewController = (ExtendedInfoTabViewController *)[viewControllers firstObject];
    tabViewController.altitude = self.altitude;
    tabViewController.route = self.route;
    tabViewController.db = self.db;
    //NSLog([NSString stringWithFormat:@"%lu", (unsigned long)[viewControllers count]]);
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   // self.navigationBar.topItem.title = self.route.getName;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"NavViewController segue");
}*/


#pragma mark - UIViewControllerTransitioningDelegate
-(UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
    
    return [[RoundRectPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

@end
