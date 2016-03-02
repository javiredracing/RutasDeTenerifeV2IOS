//
//  AltitudeViewController.h
//  RutasDeTenerife2
//
//  Created by javi on 11/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Charts;

@interface AltitudeViewController : UIViewController<ChartViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *cumulateElevationView;

@property (weak, nonatomic) IBOutlet UILabel *cumulateElevationDown;
@property (weak, nonatomic) IBOutlet UILabel *cumulateElevationUp;

//https://github.com/danielgindi/ios-charts
@property (weak, nonatomic) IBOutlet LineChartView *lineChartView;

@property NSMutableArray *altitude;
@property double distance;

@end
