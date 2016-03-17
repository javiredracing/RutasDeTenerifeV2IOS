//
//  ForecastCell.m
//  RutasDeTenerife2
//
//  Created by javi on 12/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "ForecastCell.h"

@implementation ForecastCell

- (void)awakeFromNib {
    // Initialization code
    self.mainDate.textColor = [UIColor whiteColor];
    self.mainTitle.textColor = [UIColor whiteColor];
    self.forecastView.backgroundColor = [UIColor clearColor];
    //self.mainTitle.text = @"Previsión";
    self.windPrevision.backgroundColor = [UIColor clearColor];
    self.moonrise.backgroundColor =[UIColor clearColor];
    self.moonset.backgroundColor = [UIColor clearColor];
    self.sunrise.backgroundColor = [UIColor clearColor];
    self.sunset.backgroundColor = [UIColor clearColor];
    self.rainPrev.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setForecast:(NSString *)date :(NSString *)maxTemp :(NSString *)minTemp :(NSString *)description :(NSString*) iconCode :(NSString *)windSpeed :(NSString *)windDirec :(NSString *)rainfall :(NSString *)sunset :(NSString *)sunrise :(NSString *)moonset :(NSString *)moonrise :(NSString *)countryCode{

    
    self.mainDate.text = date;
    
    NSString *maxMinC = @"";
    if ([countryCode isEqualToString:@"US"]){
        maxMinC = [NSString stringWithFormat:@"%@ ºF - %@ ºF",maxTemp,minTemp];
    }else{
         maxMinC = [NSString stringWithFormat:@"%@ ºC - %@ ºC",maxTemp,minTemp];
    }
    
    NSString *windDesc = [NSString stringWithFormat:@"%@ km/h (%@)",windSpeed,windDirec];
    if ([countryCode isEqualToString:@"US"] || [countryCode isEqualToString:@"UK"]){
        windDesc = [NSString stringWithFormat:@"%@ miles/h (%@)",windSpeed, windDirec];
    }
    
    //[self.prevision updateFields:maxMinC :description :[UIImage imageNamed:[NSString stringWithFormat:@"i%@",iconCode]] ];
    self.condImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"i%@",iconCode]];
    self.condLabel.text = maxMinC;
    self.descLabel.text = description;
    
    [self.windPrevision updateFields:@"Viento" :windDesc :[UIImage imageNamed:@"wind"]];
    [self.rainPrev setItems:[NSString stringWithFormat:@"%@ Lm2",rainfall] :[UIImage imageNamed:@"umbrella_drizzle"] ];
    [self.sunrise setItems:sunrise :[UIImage imageNamed:@"sunrise"]];
    [self.sunset setItems:sunset :[UIImage imageNamed:@"sunset"]];
    [self.moonrise setItems:moonrise :[UIImage imageNamed:@"moonrise"]];
    [self.moonset setItems:moonset :[UIImage imageNamed:@"moonset"]];
}
@end
