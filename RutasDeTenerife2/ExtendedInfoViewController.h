//
//  ExtendedInfoViewController.h
//  RutasDeTenerife2
//
//  Created by javi on 2/12/15.
//  Copyright © 2015 JAVI. All rights reserved.
//

//#import "ViewController.h"
#import "Route.h"
#import "FieldView.h"

@interface ExtendedInfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet FieldView *distance;
@property Route *route;
@property (weak, nonatomic) IBOutlet UILabel *info;
- (IBAction)howToGet:(UIButton *)sender;
- (IBAction)downloadTrack:(UIButton *)sender;


@end
