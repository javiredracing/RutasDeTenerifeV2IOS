//
//  QuickInfoView.h
//  RutasDeTenerife2
//
//  Created by javi on 25/11/15.
//  Copyright © 2015 JAVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@interface QuickInfoView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *dificult;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UIImageView *iconType;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UIView *infoView;

-(void)changeContent: (NSString *)newTitle :(float )newDistance :(int) newDifficult : (int)newIconType;

@end
