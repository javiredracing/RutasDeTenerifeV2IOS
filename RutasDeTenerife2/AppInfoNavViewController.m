//
//  AppInfoNavViewController.m
//  RutasDeTenerife2
//
//  Created by javi on 4/2/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "AppInfoNavViewController.h"
#import "RoundRectPresentationController.h"
@interface AppInfoNavViewController ()

@end

@implementation AppInfoNavViewController

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
    // Do any additional setup after loading the view.
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:0];
    [label setTextColor:[UIColor grayColor]];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    //self.navigationItem.titleView = label;
    [label setText:NSLocalizedString(@"app_name", @"")];
    self.navigationBar.topItem.titleView = label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Info"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIViewControllerTransitioningDelegate
-(UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
    
    return [[RoundRectPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

@end
