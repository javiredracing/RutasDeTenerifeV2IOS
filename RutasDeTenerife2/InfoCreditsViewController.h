//
//  InfoCreditsViewController.h
//  RutasDeTenerife2
//
//  Created by javi on 4/2/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconInfoView.h"
#import <MessageUI/MessageUI.h>
#import "Toast/UIView+Toast.h"

@interface InfoCreditsViewController : UIViewController<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UITextView *textLegal;
- (IBAction)sendEmail:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet IconInfoView *appInfo;

@end
