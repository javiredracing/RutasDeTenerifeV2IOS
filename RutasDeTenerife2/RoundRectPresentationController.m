//
//  RoundRectPresentationController.m
//  RutasDeTenerife2
//
//  Created by javi on 2/12/15.
//  Copyright © 2015 JAVI. All rights reserved.
//

#import "RoundRectPresentationController.h"

@interface RoundRectPresentationController ()

    @property (nonatomic, readonly) UIView *dimmingView;
@end

@implementation RoundRectPresentationController


-(UIView *)dimmingView{
    static UIView *instance = nil;
    if (instance == nil){
        instance = [[UIView alloc] initWithFrame:self.containerView.bounds];
        instance.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return instance;
}

-(void)presentationTransitionWillBegin{

    UIView *presentedView = self.presentedViewController.view;
    presentedView.layer.cornerRadius = 5.f;
    presentedView.layer.shadowColor = [[UIColor blackColor]CGColor];
    presentedView.layer.shadowOffset = CGSizeMake(0, 10);
    presentedView.layer.shadowRadius = 10;
    presentedView.layer.shadowOpacity = 0.5;
    
    self.dimmingView.frame = self.containerView.bounds;
    self.dimmingView.alpha = 0;
    [self.containerView addSubview:self.dimmingView];
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.alpha = 1;
    } completion:nil];
}

-(void)presentationTransitionDidEnd:(BOOL)completed{
    if (!completed)
        [self.dimmingView removeFromSuperview];
}

-(void)dismissalTransitionWillBegin{
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.alpha = 0;
    } completion:nil];

}

-(void)dismissalTransitionDidEnd:(BOOL)completed{
    if (completed)
        [self.dimmingView removeFromSuperview];
}

-(CGRect)frameOfPresentedViewInContainerView{
    CGFloat size = 280;
    CGFloat heightSize = 440;
     if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
         size = 380;
         heightSize = 540;
     }
    CGRect frame = CGRectMake((self.containerView.frame.size.width - size)/2,
     (self.containerView.frame.size.height - heightSize) / 2, size, heightSize);
    NSLog(NSStringFromCGRect(frame));

    return frame;
}

-(void)containerViewWillLayoutSubviews{
    self.dimmingView.frame = self.containerView.bounds;
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
}


@end
