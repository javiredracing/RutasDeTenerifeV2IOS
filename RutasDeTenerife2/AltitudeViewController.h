//
//  AltitudeViewController.h
//  RutasDeTenerife2
//
//  Created by javi on 11/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMSimpleLineGraphView.h"

@interface AltitudeViewController : UIViewController<BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource>

@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *graphView;

@property NSMutableArray *altitude;
@property double distance;

@end
