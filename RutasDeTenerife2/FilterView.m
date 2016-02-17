//
//  FilterView.m
//  RutasDeTenerife2
//
//  Created by javi on 16/2/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "FilterView.h"

@implementation FilterView{
    NSUserDefaults *preferences;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        UIView *xibView = [[[NSBundle mainBundle]loadNibNamed:@"FilterView" owner:self options:nil]objectAtIndex:0];
        [xibView setFrame:frame];
        [self addSubview:xibView];
    }
    return self;
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
    preferences = [NSUserDefaults standardUserDefaults];
    if ([preferences objectForKey:@"durac"] != nil){
        //  Get current level
        value = (int)[preferences integerForKey:@"durac"];
    }
    self.duracLabel.text = [NSString stringWithFormat:@"Duración %@",[self filterDistance:value]];
    value = 0;
    if ([preferences objectForKey:@"distance"] != nil){
        //  Get current level
        value = (int)[preferences integerForKey:@"distance"];
    }
    self.distanceLabel.text = [NSString stringWithFormat:@"Distancia %@",[self filterDistance:value]];
    value = 0;
    if ([preferences objectForKey:@"dific"] != nil){
        //  Get current level
        value = (int)[preferences integerForKey:@"dific"];
    }
    self.difficultLabel.text = [NSString stringWithFormat:@"Dificultad %@",[self filterDific:value]];

}

- (IBAction)duracSlider:(UISlider *)sender {
    int value = [self setTickSlider:sender];
    self.duracLabel.text = [NSString stringWithFormat:@"Duración %@",[self filterDistance:value]];
}

- (IBAction)difficultySlider:(UISlider *)sender {
    int value = [self setTickSlider:sender];
    self.difficultLabel.text = [NSString stringWithFormat:@"Dificultad %@",[self filterDific:value]];
}

- (IBAction)distanceSlider:(UISlider *)sender {
    int value = [self setTickSlider:sender];
    self.distanceLabel.text = [NSString stringWithFormat:@"Distancia %@",[self filterDistance:value]];
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
            textItem = @"facil";
            break;
        case 2:
             textItem = @"medio";
            break;
        case 3:
             textItem = @"dificil";
            break;
        default:
            textItem = @"todos";
            break;
    }
    return textItem;
}

-(NSString *)filterDistance :(int)value{
    NSString *textItem;
    switch (value) {
        case 1:
            textItem = @"corto";
            break;
        case 2:
            textItem = @"medio";
            break;
        case 3:
            textItem = @"largo";
            break;
        default:
            textItem = @"todos";
            break;
    }
    return textItem;
}



@end
