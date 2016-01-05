//
//  ExtendedInfoTabViewController.m
//  RutasDeTenerife2
//
//  Created by Javi on 3/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "ExtendedInfoTabViewController.h"
#import "ExtendedInfoViewController.h"

@interface ExtendedInfoTabViewController ()

@end

@implementation ExtendedInfoTabViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"TABController loaded");
    NSArray *viewControllers = [self viewControllers];
    ExtendedInfoViewController *descriptionController = (ExtendedInfoViewController *)[viewControllers firstObject];
    descriptionController.route = self.route;
    NSLog([NSString stringWithFormat:@"TABControllers count: %lu", (unsigned long)[viewControllers count]]);
   // NSLog([NSString stringWithFormat:@"Name tab %@",[self.route getName] ]);
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


- (IBAction)closeInfo:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
