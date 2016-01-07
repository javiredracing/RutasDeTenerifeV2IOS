//
//  FieldView.m
//  RutasDeTenerife2
//
//  Created by javi on 7/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "FieldView.h"

@implementation FieldView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    if ((self = [super initWithCoder:aDecoder])){
        /*  UIView *v = [[[NSBundle mainBundle] loadNibNamed:@"QuickInfo"
         owner:self
         options:nil] objectAtIndex:0];
         [v sizeToFit];
         [self addSubview:v];
         */
        
        // 1. load the interface
        [[NSBundle mainBundle] loadNibNamed:@"FieldView" owner:self options:nil];
        // 2. add as subview
        //[self.infoView sizeToFit];
        [self addSubview:self.infoView];
        // 3. allow for autolayout
        [self.infoView setTranslatesAutoresizingMaskIntoConstraints:NO];
        // 4. add constraints to span entire view
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":self.infoView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self.infoView}]];
        
    }
    return self;
}

@end
