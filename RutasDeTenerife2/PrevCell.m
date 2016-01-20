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

-(void)setCurrentCond:(NSString *)hour :(NSString *)iconCode :(NSString *)temperature :(NSString *)description :(NSString *)wind :(NSString *)windDirec :(NSString *)cloudly :(NSString *)humidity :(NSString *)pressure :(NSString *)rainfall :(NSString *)countryCode{

    self.currentCondTitle.text = @"Condiciones actuales";
    self.currentDate.text = hour;
    NSString *temperatureText = [NSString stringWithFormat:@"%@ ºC",temperature];;
    if ([countryCode isEqualToString:@"US"]){
        temperatureText = [NSString stringWithFormat:@"%@ ºF",temperature];
    }
    
    NSString *windSpeedText = [NSString stringWithFormat:@"%@ km/h (%@)",wind, windDirec];
    if ([countryCode isEqualToString:@"US"] || [countryCode isEqualToString:@"UK"]){
       windSpeedText = [NSString stringWithFormat:@"%@ miles/h (%@)",wind, windDirec];
    }
    [self.currentTemp updateFields:temperatureText :description :[UIImage imageNamed:[NSString stringWithFormat:@"i%@",iconCode]] ];
    [self.currentWind updateFields:@"Viento" :windSpeedText :[UIImage imageNamed:@"wind"]];
    self.condAtmosf.text = @"Cond. atmosfericas";
    self.nubosity.text = [NSString stringWithFormat:@"Nubosidad: %@",cloudly];
    self.humidity.text = [NSString stringWithFormat:@"Humedad: %@",humidity];
    self.pressure.text = [NSString stringWithFormat:@"Presión: %@", pressure];
    self.rainfall.text = [NSString stringWithFormat:@"Lluvia: %@",rainfall];
}

@end
