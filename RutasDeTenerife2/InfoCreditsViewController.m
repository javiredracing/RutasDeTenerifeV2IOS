//
//  InfoCreditsViewController.m
//  RutasDeTenerife2
//
//  Created by javi on 4/2/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "InfoCreditsViewController.h"
#import <Google/Analytics.h>

@interface InfoCreditsViewController ()

@end

@implementation InfoCreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIColor *lightGreenColor = [UIColor colorWithRed:(187.0 / 255.0) green:(234.0 / 255.0) blue:(176.0 / 255.0) alpha:1.0];
    
    self.appInfo.layer.borderColor = lightGreenColor.CGColor;
    self.btnSend.layer.borderColor = lightGreenColor.CGColor;
    self.btnSend.layer.shadowColor = [UIColor blackColor].CGColor;
    self.btnSend.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.btnSend.layer.shadowOpacity = 0.8;
    self.btnSend.layer.shadowRadius = 5.0;
    if (![MFMailComposeViewController canSendMail]) {
        self.btnSend.enabled = NO;
    }
    UIColor *startGray = [UIColor colorWithRed:(204.0 / 255.0) green:(202.0 / 255.0) blue:(202.0 / 255.0) alpha:1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [self.view bounds];
    gradient.colors = [NSArray arrayWithObjects:(id)[startGray CGColor], (id)[[UIColor lightGrayColor] CGColor], nil];
    gradient.startPoint = CGPointZero;
    gradient.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void) viewDidLayoutSubviews{
    //textview scroll start on top
    self.textLegal.textColor = [UIColor whiteColor];
    [self.textLegal setContentOffset:CGPointZero animated:NO];
}
- (IBAction)sendEmail:(UIButton *)sender {

        NSString *emailTitle = NSLocalizedString(@"app_name", @"");
        // Email Content
        NSString *messageBody = @"";
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:@"rutastenerife@gmail.com"];
        MFMailComposeViewController *mc;
        mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *message;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            message =  NSLocalizedString(@"mail_cancelled", @"");
            break;
        case MFMailComposeResultSaved:
            message = NSLocalizedString(@"mail_saved", @"");
            break;
        case MFMailComposeResultSent:{
            message = NSLocalizedString(@"mail_sent", @"");
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"button_press"  // Event action (required)
                                                                   label:@"play"          // Event label
                                                                   value:nil] build]];
            }
            break;
        
        case MFMailComposeResultFailed:
            message = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"mail_failure", @""), [error localizedDescription]];
            break;
        default:
            message = @"";
            break;
    }
    
     [self.view makeToast:message];
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
