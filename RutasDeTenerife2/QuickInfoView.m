//
//  QuickInfoView.m
//  RutasDeTenerife2
//
//  Created by javi on 25/11/15.
//  Copyright © 2015 JAVI. All rights reserved.
//

#import "QuickInfoView.h"

@implementation QuickInfoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

/*-(id)initWithCoder:(NSCoder *)aDecoder{

    if ((self = [super initWithCoder:aDecoder])){
        UIView *v = [[[NSBundle mainBundle] loadNibNamed:@"QuickInfo"
                                                   owner:self
                                                 options:nil] objectAtIndex:0];
        [v sizeToFit];
        [self addSubview:v];
    }
    return self;
}*/

-(id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    
    // without this check you'll end up with a recursive loop - we need to know that we were loaded from our view xib vs the storyboard.
    // set the view tag in the MyView xib to be -999 and anything else in the storyboard.
    if ( self.tag == -999 )
    {
        return self;
    }
    
    // make sure your custom view is the first object in the nib
    QuickInfoView* v = [[[UINib nibWithNibName: @"QuickInfo" bundle: nil] instantiateWithOwner: nil options: nil] firstObject];
    
    // copy properties forward from the storyboard-decoded object (self)
         v.frame = self.frame;
    v.autoresizingMask = self.autoresizingMask;
    v.translatesAutoresizingMaskIntoConstraints = self.translatesAutoresizingMaskIntoConstraints;
    v.tag = self.tag;
    [v sizeToFit];

    // copy any other attribtues you want to set in the storyboard
    
    // possibly copy any child constraints for width/height
    
    return v;
}

/*-(id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    
    if (self)
    {
        [self addSubview:
         [[[NSBundle mainBundle] loadNibNamed:@"QuickInfo"
                                        owner:self
                                      options:nil] objectAtIndex:0]];
        
    }
    
    return self;
}*/

@end
