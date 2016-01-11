//
//  ExtInfoNavViewController.h
//  RutasDeTenerife2
//
//  Created by javi on 4/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Route.h"
#import "Database.h"

@interface ExtInfoNavViewController : UINavigationController

@property Route *route;
@property NSMutableArray *altitude;
@property Database *db;

@end
