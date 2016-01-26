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
    self.graphView.enableXAxisLabel = YES;
    self.graphView.enableReferenceXAxisLines = YES;
    self.graphView.enableReferenceYAxisLines = YES;
    self.graphView.enableReferenceAxisFrame = YES;
    self.graphView.delegate = self;
    self.graphView.dataSource = self;
    self.graphView.animationGraphStyle = BEMLineAnimationNone;
    //self.graphView.enableBezierCurve = YES;
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
 // Number of points in the graph
-(NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph{
    return [self.altitude count];
}

// The value of the point on the Y-Axis for the index.
-(CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index{
    CGFloat value =[[self.altitude objectAtIndex:index] doubleValue];
    return value;
}

#pragma mark - SimpleLineGraph Delegate

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    float value = ([self.altitude count] / 5);
    NSNumber *myNumber = [NSNumber numberWithFloat:value];
    NSInteger myInt = [myNumber intValue];
    return myInt;
}

-(NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index{
    NSLog([NSString stringWithFormat:@"Log %d",(int)index]);
    float value = (self.distance * index)/[self.altitude count];
    return [NSString stringWithFormat:@"%.1f",value];
}

-(void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph{
    NSLog(@"finishing loading");
    //TODO calculate elevation MAX and MIN
}
@end
