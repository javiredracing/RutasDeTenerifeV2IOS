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
#import "Database.h"

@interface ExtendedInfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *tvDecription;
@property (weak, nonatomic) IBOutlet UIButton *btDownload;
@property (weak, nonatomic) IBOutlet UIButton *btHowToGet;
@property (weak, nonatomic) IBOutlet FieldView *approved;
@property (weak, nonatomic) IBOutlet FieldView *time;
@property (weak, nonatomic) IBOutlet FieldView *difficult;
@property (weak, nonatomic) IBOutlet FieldView *distance;
@property Route *route;
@property Database *db;

- (IBAction)howToGet:(UIButton *)sender;
- (IBAction)downloadTrack:(UIButton *)sender;


@end
