//
//  FilterView.h
//  RutasDeTenerife2
//
//  Created by javi on 16/2/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterView : UIView

@property (weak, nonatomic) IBOutlet UILabel *duracLabel;
@property (weak, nonatomic) IBOutlet UILabel *difficultLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

- (IBAction)duracSlider:(UISlider *)sender;
- (IBAction)difficultySlider:(UISlider *)sender;
- (IBAction)distanceSlider:(UISlider *)sender;

@end
