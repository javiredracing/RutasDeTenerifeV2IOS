//
//  MainInfoViewController.m
//  RutasDeTenerife2
//
//  Created by javi on 10/2/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "MainInfoViewController.h"

@interface MainInfoViewController ()

@end

@implementation MainInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
-(void) viewDidLayoutSubviews{
    //textview scroll start on top
    [self.infoTV setContentOffset:CGPointZero animated:NO];
}

@end
