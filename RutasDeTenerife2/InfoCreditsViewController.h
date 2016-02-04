//
//  InfoCreditsViewController.h
//  RutasDeTenerife2
//
//  Created by javi on 4/2/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconInfoView.h"

@interface InfoCreditsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UITextView *textLegal;
- (IBAction)sendEmail:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet IconInfoView *appInfo;

@end
