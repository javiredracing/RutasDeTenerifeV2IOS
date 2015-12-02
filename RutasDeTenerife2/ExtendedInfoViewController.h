//
//  ExtendedInfoViewController.h
//  RutasDeTenerife2
//
//  Created by javi on 2/12/15.
//  Copyright © 2015 JAVI. All rights reserved.
//

//#import "ViewController.h"
#import "Route.h"

@interface ExtendedInfoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *info;
- (IBAction)closeBt:(id)sender;

@property Route *route;

@end
