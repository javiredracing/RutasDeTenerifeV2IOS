//
//  IconInfoView.h
//  RutasDeTenerife2
//
//  Created by javi on 13/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IconInfoView : UIView
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (strong, nonatomic) IBOutlet UIView *currentView;

-(void)setItems: (NSString *)title :(UIImage *)icon;

@end
