//
//  FieldView.h
//  RutasDeTenerife2
//
//  Created by javi on 7/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FieldView : UIView
@property (strong, nonatomic) IBOutlet UIView *mainView;


@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *image;



-(void)updateFields :(NSString *)title :(NSString *)content :(UIImage *)icon;

@end
