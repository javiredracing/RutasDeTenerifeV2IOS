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
        //
    self.lineChartView.delegate = self;
    
    self.lineChartView.descriptionText = @"";
    self.lineChartView.noDataTextDescription = @"You need to provide data for the chart.";
    [self.lineChartView setScaleEnabled:YES];
    self.lineChartView.backgroundColor = [UIColor colorWithWhite:204/255.f alpha:1.f];
    ChartYAxis *leftAxis = self.lineChartView.leftAxis;
    
    //[leftAxis removeAllLimitLines];
    //[leftAxis addLimitLine:ll1];
    //[leftAxis addLimitLine:ll2];
    leftAxis.customAxisMax = 3700.0;
    leftAxis.customAxisMin = 0;
    leftAxis.startAtZeroEnabled = NO;
    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
    
    self.lineChartView.rightAxis.enabled = NO;
    
    [self.lineChartView.viewPortHandler setMaximumScaleY: 2.f];
    [self.lineChartView.viewPortHandler setMaximumScaleX: 2.f];

    self.lineChartView.legend.form = ChartLegendFormLine;
    self.lineChartView.legend.position = ChartLegendPositionBelowChartLeft;
    ChartXAxis *xAxis = self.lineChartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelTextColor = UIColor.redColor;
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData{
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    NSUInteger count = [self.altitude count];
    double interval = (self.distance / (double)count);
    double currentDistance = 0.0;
    
    for (int i = 0; i < count; i++)
    {
        [xVals addObject:[NSString stringWithFormat:@"%.1f",currentDistance]];
        currentDistance = currentDistance + interval;
    }
    //[xVals addObject:[NSString stringWithFormat:@"%.1f",self.distance]];
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];

    for (int i = 0; i < count; i++)
    {
        double val = [[self.altitude objectAtIndex:i] doubleValue];
        [yVals addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
    }
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:yVals label:@"metros / Km"];
    
    set1.lineDashLengths = @[@5.f, @2.5f];
    set1.highlightLineDashLengths = @[@5.f, @2.5f];
    [set1 setColor:UIColor.blackColor];
    [set1 setCircleColor:UIColor.blackColor];
    set1.lineWidth = 1.0;
    set1.circleRadius = 0.0;
    set1.drawCircleHoleEnabled = NO;
    set1.valueFont = [UIFont systemFontOfSize:9.f];
    
    NSArray *gradientColors = @[
                                (id)[ChartColorTemplates colorFromString:@"#00ff0000"].CGColor,
                                (id)[ChartColorTemplates colorFromString:@"#ffff0000"].CGColor
                                ];
    CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
    
    set1.fillAlpha = 1.f;
    set1.fill = [ChartFill fillWithLinearGradient:gradient angle:90.f];
    set1.drawFilledEnabled = YES;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
    
    self.lineChartView.data = data;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
