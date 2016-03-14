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
    self.currentDegreeView.backgroundColor = [UIColor clearColor];
    self.rainfall.textColor = [UIColor whiteColor];
    self.humidity.textColor = [UIColor whiteColor];
    self.pressure.textColor = [UIColor whiteColor];
    self.nubosity.textColor = [UIColor whiteColor];
    self.condAtmosf.textColor = [UIColor whiteColor];
    self.currentDate.textColor = [UIColor whiteColor];
    self.currentCondTitle.textColor = [UIColor whiteColor];
    self.currentCondTitle.text = @"Condiciones actuales";
    self.condAtmosf.text = @"Cond. atmosfericas";
    self.currentWind.backgroundColor = [UIColor clearColor];
    self.codicView.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCurrentCond:(NSString *)hour :(NSString *)iconCode :(NSString *)temperature :(NSString *)description :(NSString *)wind :(NSString *)windDirec :(NSString *)cloudly :(NSString *)humidity :(NSString *)pressure :(NSString *)rainfall :(NSString *)countryCode{

    
    self.currentDate.text = hour;
    NSString *temperatureText = [NSString stringWithFormat:@"%@ ºC",temperature];;
    if ([countryCode isEqualToString:@"US"]){
        temperatureText = [NSString stringWithFormat:@"%@ ºF",temperature];
    }
    
    NSString *windSpeedText = [NSString stringWithFormat:@"%@ km/h (%@)",wind, windDirec];
    if ([countryCode isEqualToString:@"US"] || [countryCode isEqualToString:@"UK"]){
       windSpeedText = [NSString stringWithFormat:@"%@ miles/h (%@)",wind, windDirec];
    }
    //[self.currentTemp updateFields:temperatureText :description :[UIImage imageNamed:[NSString stringWithFormat:@"i%@",iconCode]] ];
    self.weatherImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"i%@",iconCode]];
    self.degreesLabel.text = temperatureText;
    self.descWeatherLabel.text = description;
    [self.currentWind updateFields:@"Viento" :windSpeedText :[UIImage imageNamed:@"wind"]];
    
    self.nubosity.text = [NSString stringWithFormat:@"Nubosidad: %@%%",cloudly];
    self.humidity.text = [NSString stringWithFormat:@"Humedad: %@%%",humidity];
    self.pressure.text = [NSString stringWithFormat:@"Presión: %@ mb", pressure];
    self.rainfall.text = [NSString stringWithFormat:@"Lluvia: %@ lm2",rainfall];
}

@end
