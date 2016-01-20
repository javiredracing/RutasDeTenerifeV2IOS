//
//  PrevCell.h
//  RutasDeTenerife2
//
//  Created by javi on 12/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FieldView.h"

@interface PrevCell : UITableViewCell

@property (weak, nonatomic) IBOutlet FieldView *currentTemp;

@property (weak, nonatomic) IBOutlet UILabel *rainfall;
@property (weak, nonatomic) IBOutlet UILabel *humidity;
@property (weak, nonatomic) IBOutlet UILabel *pressure;
@property (weak, nonatomic) IBOutlet UILabel *nubosity;
@property (weak, nonatomic) IBOutlet UILabel *condAtmosf;
@property (weak, nonatomic) IBOutlet UILabel *currentDate;
@property (weak, nonatomic) IBOutlet UILabel *currentCondTitle;
@property (weak, nonatomic) IBOutlet FieldView *currentWind;

-(void)setCurrentCond: (NSString*)hour :(NSString *)iconCode :(NSString*)temperature :(NSString *)description :(NSString *)wind :(NSString *)windDirec :(NSString *)cloudly :(NSString *)humidity :(NSString *)pressure :(NSString *)rainfall :(NSString *)countryCode;
@end
