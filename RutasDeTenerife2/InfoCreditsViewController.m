//
//  InfoCreditsViewController.m
//  RutasDeTenerife2
//
//  Created by javi on 4/2/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "InfoCreditsViewController.h"

@interface InfoCreditsViewController ()

@end

@implementation InfoCreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.btnSend.layer.shadowColor = [UIColor grayColor].CGColor;
    self.btnSend.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.btnSend.layer.shadowOpacity = 0.8;
    self.btnSend.layer.shadowRadius = 0.0;
    
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
    [self.textLegal setContentOffset:CGPointZero animated:NO];
}
- (IBAction)sendEmail:(UIButton *)sender {
}
@end
