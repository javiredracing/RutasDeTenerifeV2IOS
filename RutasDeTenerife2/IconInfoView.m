//
//  IconInfoView.m
//  RutasDeTenerife2
//
//  Created by javi on 13/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "IconInfoView.h"

@implementation IconInfoView

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
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        // [[NSBundle mainBundle] loadNibNamed:@"FieldView" owner:self options:nil];
        // 2. add as subview
        //[self.infoView sizeToFit];
        [self addSubview:self.currentView];
        // 3. allow for autolayout
        [self.currentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        // 4. add constraints to span entire view
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":self.currentView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self.currentView}]];
        
    }
    return self;
}

-(void)setItems:(NSString *)title :(UIImage *)icon{
    self.icon.image = icon;
    self.title.text = title;
}

@end
