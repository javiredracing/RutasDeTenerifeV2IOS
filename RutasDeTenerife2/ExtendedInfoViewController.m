//
//  ExtendedInfoViewController.m
//  RutasDeTenerife2
//
//  Created by javi on 2/12/15.
//  Copyright © 2015 JAVI. All rights reserved.
//

#import "ExtendedInfoViewController.h"
//#import "RoundRectPresentationController.h"

@interface ExtendedInfoViewController ()/*<UIViewControllerTransitioningDelegate>*/

@end

@implementation ExtendedInfoViewController

/*-(instancetype) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([self respondsToSelector:@selector(setTransitioningDelegate:)]){
            self.modalPresentationStyle = UIModalPresentationCustom;
            self.transitioningDelegate = self;
        }
    }
    return self;
}*/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed:@"distance32"];
    
    [self.distance updateFields:@"Distance" :[NSString stringWithFormat:@"%.02f",[self.route getDist]] :image];
    [self.difficult updateFields:@"Difficult" :[NSString stringWithFormat:@"%d",[self.route getDifficulty]] :[UIImage imageNamed:@"nivel_facil"]];
    [self.time updateFields:@"Duración" :[NSString stringWithFormat:@"%.02f",[self.route getDurac]] :[UIImage imageNamed:@"timer"]];
    [self.approved updateFields:@"Homologado" :@"Si" :[UIImage imageNamed:@"marker_sign_24"]];
    self.btHowToGet.layer.shadowColor = [UIColor grayColor].CGColor;
    self.btHowToGet.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.btHowToGet.layer.shadowOpacity = 0.8;
    self.btHowToGet.layer.shadowRadius = 0.0;
    
    self.btDownload.layer.shadowColor = [UIColor grayColor].CGColor;
    self.btDownload.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.btDownload.layer.shadowOpacity = 0.8;
    self.btDownload.layer.shadowRadius = 0.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}*/


- (IBAction)closeBt:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*#pragma mark - UIViewControllerTransitioningDelegate
-(UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{

    return [[RoundRectPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}*/
- (IBAction)howToGet:(UIButton *)sender {
}
- (IBAction)downloadTrack:(UIButton *)sender {
}
@end
