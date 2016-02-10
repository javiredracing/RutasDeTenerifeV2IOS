//
//  InfoCreditsViewController.m
//  RutasDeTenerife2
//
//  Created by javi on 4/2/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "InfoCreditsViewController.h"

@interface InfoCreditsViewController ()

@end

@implementation InfoCreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.btnSend.layer.shadowColor = [UIColor blackColor].CGColor;
    self.btnSend.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.btnSend.layer.shadowOpacity = 0.8;
    self.btnSend.layer.shadowRadius = 5.0;
    if (![MFMailComposeViewController canSendMail]) {
        self.btnSend.enabled = NO;
    }
    
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
    [self.textLegal setContentOffset:CGPointZero animated:NO];
}
- (IBAction)sendEmail:(UIButton *)sender {

        NSString *emailTitle = @"Rutas de Tenerife";
        // Email Content
        NSString *messageBody = @"iOS programming is so fun!";
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
            message = @"Mail cancelled";
           
            break;
        case MFMailComposeResultSaved:
            message = @"Mail saved";
            break;
        case MFMailComposeResultSent:
            message =@"Mail sent";
            break;
        case MFMailComposeResultFailed:
           /* NSString *str = [NSString stringWithFormat:@"%@", [error localizedDescription]];
            message =  str;*/
            break;
        default:
            break;
    }
    
     [self.view makeToast:message];
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
-(void)configureToast{
    //https://github.com/scalessec/Toast
    CSToastStyle *style = [[CSToastStyle alloc]initWithDefaultStyle];
    style.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    style.messageAlignment = NSTextAlignmentCenter;
    style.messageColor = [UIColor grayColor];
    style.cornerRadius = 5.0;
    style.borderWidth = 2.0;
    style.borderColor =[[UIColor greenColor] colorWithAlphaComponent:0.8];
    [CSToastManager setSharedStyle:style];
    [CSToastManager setQueueEnabled:NO];
}
@end
