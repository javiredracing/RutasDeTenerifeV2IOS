//
//  AltitudeViewController.m
//  RutasDeTenerife2
//
//  Created by javi on 11/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "AltitudeViewController.h"
#define V_MAX 2800.0
#define V_MIN 0.0
#define H_MAX 0.03
#define H_MIN 0.27

@interface AltitudeViewController ()

@end

@implementation AltitudeViewController{

    UIColor *lightGreenColor;
    UIColor *darkGreenColor;
    double maxValue, minValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIColor *startGray = [UIColor colorWithRed:(204.0 / 255.0) green:(202.0 / 255.0) blue:(202.0 / 255.0) alpha:1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [self.view bounds];
    gradient.colors = [NSArray arrayWithObjects:(id)[startGray CGColor], (id)[[UIColor lightGrayColor] CGColor], nil];
    gradient.startPoint = CGPointZero;
    gradient.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    lightGreenColor = [UIColor colorWithRed:(187.0 / 255.0) green:(234.0 / 255.0) blue:(176.0 / 255.0) alpha:1.0];
    darkGreenColor = [UIColor colorWithRed:(188.0/255.0) green:(231.0/255.0) blue:(94.0/255.0) alpha:1.0];
    self.cumulateElevationView.layer.borderColor = lightGreenColor.CGColor;
    self.lineChartView.layer.borderColor = lightGreenColor.CGColor;
        //
    self.lineChartView.delegate = self;
    
    self.lineChartView.descriptionText = @"";
    self.lineChartView.noDataTextDescription = @"You need to provide data for the chart.";
    [self.lineChartView setScaleEnabled:YES];
    self.lineChartView.backgroundColor = [UIColor clearColor];
    ChartYAxis *leftAxis = self.lineChartView.leftAxis;
    leftAxis.labelTextColor = [UIColor whiteColor];
    //[leftAxis removeAllLimitLines];
    //[leftAxis addLimitLine:ll1];
    //[leftAxis addLimitLine:ll2];
    maxValue = [self maxValue:self.altitude] + 400;
    if (maxValue < 500)
        maxValue = 500;
    leftAxis.customAxisMax = maxValue;
    minValue = [self minValue:self.altitude];
    if (minValue > 500)
        minValue = 500;
    else
        minValue= 0;
    leftAxis.customAxisMin = minValue;
    leftAxis.startAtZeroEnabled = NO;
    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
    
    self.lineChartView.rightAxis.enabled = NO;
    
    [self.lineChartView.viewPortHandler setMaximumScaleY: 2.f];
    [self.lineChartView.viewPortHandler setMaximumScaleX: 2.f];

    self.lineChartView.legend.form = ChartLegendFormLine;
    self.lineChartView.legend.position = ChartLegendPositionBelowChartLeft;
    
    ChartXAxis *xAxis = self.lineChartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelTextColor = [UIColor whiteColor];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData{

    NSUInteger count = [self.altitude count];
    double interval = (self.distance / (double)count);
    double currentDistance = 0.0;
    
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    double netAlt = 0.0;
    double netDown = 0.0;

    for (NSUInteger i = 0; i < count; i++){
        [xVals addObject:[NSString stringWithFormat:@"%.1f",currentDistance]];
        currentDistance = currentDistance + interval;
        
        double val = [[self.altitude objectAtIndex:i] doubleValue];
        [yVals addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
        
        if (i > 0){
            double oldAlt = [[self.altitude objectAtIndex:(i - 1)] doubleValue];
            double newAlt = val;
            double diff = newAlt - oldAlt;
            netAlt = netAlt + fmax(0.0, diff);
            netDown = netDown - fmin(0.0, diff);
        }
    }
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:yVals label:@"metros / Km"];
    set1.lineDashLengths = @[@5.f, @2.5f];
    set1.highlightLineDashLengths = @[@5.f, @2.5f];
    [set1 setColor:darkGreenColor];
    //[set1 setCircleColor:UIColor.blackColor];
    set1.lineWidth = 1.0;
    set1.circleRadius = 0.0;
    set1.drawCircleHoleEnabled = NO;
    set1.valueFont = [UIFont systemFontOfSize:9.f];
    
    /*NSArray *gradientColors = @[
                                (id)[ChartColorTemplates colorFromString:@"#BBEAB0"].CGColor,
                                (id)[ChartColorTemplates colorFromString:@"#bce75e"].CGColor
                                ];*/
    NSArray *gradientColors = @[
                                (id)[self getColor:[self minValue:self.altitude]],
                                (id)[self getColor:[self maxValue:self.altitude]]
                                ];

    CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
    
    set1.fillAlpha = .7f;
    set1.fill = [ChartFill fillWithLinearGradient:gradient angle:90.f];
    set1.drawFilledEnabled = YES;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
    
    self.lineChartView.data = data;
    /*Update elevation labels*/
    self.cumulateElevationUp.text = [NSString stringWithFormat:@"%.1f m",netAlt];
    self.cumulateElevationDown.text = [NSString stringWithFormat:@"%.1f m",fabs(netDown)];
}

-(double)maxValue :(NSMutableArray *)items{
    double value = 0.0;
    NSUInteger size = [items count];
    for (NSUInteger i = 0; i < size ; i++) {
        if ([[items objectAtIndex:i] doubleValue] > value){
            value = [[items objectAtIndex:i] doubleValue];
        }
    }
    return value;
}

-(double)minValue :(NSMutableArray *)items{
    double value = 99999.0;
    NSUInteger size = [items count];
    for (NSUInteger i = 0; i < size ; i++) {
        if ([[items objectAtIndex:i] doubleValue] < value){
            value = [[items objectAtIndex:i] doubleValue];
        }
    }
    return value;
}

//Get color interpolating
-(CGColorRef)getColor :(float)value{
    float curVelo = value;
    curVelo = ((curVelo < V_MIN) ? V_MIN : (curVelo  > V_MAX) ? V_MAX : curVelo);
    float result = H_MIN + ((curVelo-V_MIN)*(H_MAX-H_MIN))/(V_MAX-V_MIN);
    return [UIColor colorWithHue:result saturation:1.0f brightness:1.0f alpha:1.0f].CGColor;
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
