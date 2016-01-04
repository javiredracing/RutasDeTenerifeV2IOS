//
//  ExtInfoNavViewController.m
//  RutasDeTenerife2
//
//  Created by javi on 4/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "ExtInfoNavViewController.h"
#import "RoundRectPresentationController.h"


#define FONT_SIZE_DEFAULT  25

@interface ExtInfoNavViewController ()<UIViewControllerTransitioningDelegate>
@end

@implementation ExtInfoNavViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([self respondsToSelector:@selector(setTransitioningDelegate:)]){
            self.modalPresentationStyle = UIModalPresentationCustom;
            self.transitioningDelegate = self;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *faceImage = [UIImage imageNamed:@"close.png"];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    face.bounds = CGRectMake( 10, 0, faceImage.size.width, faceImage.size.height );
    [face addTarget:self action:@selector(handleBack:) forControlEvents:UIControlEventTouchUpInside];
    [face setImage:faceImage forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    self.navigationItem.leftBarButtonItem = backButton;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    [self.navigationItem setBackBarButtonItem:nil];
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
