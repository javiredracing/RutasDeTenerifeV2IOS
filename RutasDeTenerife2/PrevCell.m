//
//  PrevCell.m
//  RutasDeTenerife2
//
//  Created by javi on 12/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "PrevCell.h"

@implementation PrevCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCurrentCond:(NSString *)hour :(NSString *)iconCode :(NSString *)temperature :(NSString *)description :(NSString *)wind :(NSString *)cloudly :(NSString *)humidity :(NSString *)pressure :(NSString *)rainfall{

    self.currentCondTitle.text = @"Condiciones actuales";
    self.currentDate.text = hour;
    [self.currentTemp updateFields:[NSString stringWithFormat:@"%@ C",temperature] :description :[UIImage imageNamed:[NSString stringWithFormat:@"i%@",iconCode]] ];
    [self.currentWind updateFields:@"Viento" :wind :[UIImage imageNamed:@"wind"]];
    self.condAtmosf.text = @"Cond. atmosfericas";
    self.nubosity.text = [NSString stringWithFormat:@"Nubosidad: %@",cloudly];
    self.humidity.text = [NSString stringWithFormat:@"Humedad: %@",humidity];
    self.pressure.text = [NSString stringWithFormat:@"Presión: %@", pressure];
    self.rainfall.text = [NSString stringWithFormat:@"Lluvia: %@",rainfall];
}

@end
