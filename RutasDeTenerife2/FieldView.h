//
//  FieldView.h
//  RutasDeTenerife2
//
//  Created by javi on 7/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FieldView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UILabel *title;

@end
