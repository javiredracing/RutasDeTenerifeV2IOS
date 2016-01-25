//
//  AltitudeViewController.m
//  RutasDeTenerife2
//
//  Created by javi on 11/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "AltitudeViewController.h"

@interface AltitudeViewController ()

@end

@implementation AltitudeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.graphView.autoScaleYAxis = YES;
    self.graphView.alwaysDisplayDots = NO;
    self.graphView.enableReferenceXAxisLines = YES;
    self.graphView.enableReferenceYAxisLines = YES;
    self.graphView.enableReferenceAxisFrame = YES;
    
    double interval = (self.distance / (double)[self.altitude count]);
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

#pragma mark - SimpleLineGraph Data Source

-(NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph{
    return 1;
}

-(CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index{
    return 1.0;
}

@end
