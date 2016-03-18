//
//  FilterView.m
//  RutasDeTenerife2
//
//  Created by javi on 16/2/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "FilterView.h"

@implementation FilterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    FilterView *xibView;
    if (self){
         xibView = [[[NSBundle mainBundle]loadNibNamed:@"FilterView" owner:self options:nil]objectAtIndex:0];
        [xibView setFrame:frame];
        //[self addSubview:xibView];
    }
    return xibView;
}

/*-(id)init{
    self = [super init];
    if (self){
        UIView *xibView = [[[NSBundle mainBundle]loadNibNamed:@"FilterView" owner:self options:nil]objectAtIndex:0];
        [self addSubview:xibView];
    }
    return self;

}*/

-(void)awakeFromNib{
    NSLog(@"Loaded");
    int value = 0;
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if ([preferences objectForKey:@"durac"] != nil){
        //  Get current level
        value = (int)[preferences integerForKey:@"durac"];
    }
    self.duracLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"time", @""),[self filterDistance:value]];
    self.sliderDurac.value = value;
    value = 0;
    if ([preferences objectForKey:@"distance"] != nil){
        //  Get current level
        value = (int)[preferences integerForKey:@"distance"];
    }
    self.distanceLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"distance", @""),[self filterDistance:value]];
    self.sliderDist.value = value;
    value = 0;
    if ([preferences objectForKey:@"dific"] != nil){
        //  Get current level
        value = (int)[preferences integerForKey:@"dific"];
    }
    self.difficultLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"difficulty", @""), [self filterDific:value]];
    self.sliderDific.value = value;
    [super awakeFromNib];
}

- (IBAction)duracSlider:(UISlider *)sender {
    int value = [self setTickSlider:sender];
    self.duracLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"time", @""), [self filterDistance:value]];
}

- (IBAction)difficultySlider:(UISlider *)sender {
    int value = [self setTickSlider:sender];
    self.difficultLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"difficulty", @""), [self filterDific:value]];
}

- (IBAction)distanceSlider:(UISlider *)sender {
    int value = [self setTickSlider:sender];
    self.distanceLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"distance", @""), [self filterDistance:value]];
}

-(int)setTickSlider: (UISlider *)slider{
    int newValue = (int)roundf (slider.value + 0.25);
    //NSLog([NSString stringWithFormat:@"valor: %f, tick %d",slider.value, newValue]);
    [slider setValue:newValue animated:YES];
    return newValue;
}

-(NSString *)filterDific :(int)value{
    NSString *textItem;
    switch (value) {
        case 1:
            textItem = NSLocalizedString(@"easy", @"");
            break;
        case 2:
             textItem = NSLocalizedString(@"moderate", @"");
            break;
        case 3:
             textItem = NSLocalizedString(@"difficult", @"");
            break;
        default:
            textItem = NSLocalizedString(@"all", @"");
            break;
    }
    return textItem;
}

-(NSString *)filterDistance :(int)value{
    NSString *textItem;
    switch (value) {
        case 1:
            textItem = NSLocalizedString(@"short", @"");
            break;
        case 2:
            textItem = NSLocalizedString(@"medium", @"");
            break;
        case 3:
            textItem = NSLocalizedString(@"large", @"");
            break;
        default:
            textItem = NSLocalizedString(@"all", @"");
            break;
    }
    return textItem;
}



@end
