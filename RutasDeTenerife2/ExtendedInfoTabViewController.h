//
//  ExtendedInfoTabViewController.h
//  RutasDeTenerife2
//
//  Created by Javi on 3/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Route.h"
#import "Database.h"

@interface ExtendedInfoTabViewController : UITabBarController
- (IBAction)closeInfo:(UIBarButtonItem *)sender;

@property Route *route;
@property NSMutableArray *altitude;
@property Database *db;

@end
