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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setForecast:(NSString *)date :(NSString *)maxTemp :(NSString *)minTemp :(NSString *)description :(NSString*) iconCode :(NSString *)windSpeed :(NSString *)windDirec :(NSString *)rainfall :(NSString *)sunset :(NSString *)sunrise :(NSString *)moonset :(NSString *)moonrise{

    self.mainTitle.text = @"Previsión";
    self.mainDate.text = date;
    NSString *maxMinC = [NSString stringWithFormat:@"%@ ºC - %@ ºC",maxTemp,minTemp];
    [self.prevision updateFields:maxMinC :description :[UIImage imageNamed:[NSString stringWithFormat:@"i%@",iconCode]] ];
    NSString *windDesc = [NSString stringWithFormat:@"%@ km/h (%@)",windSpeed,windDirec];
    [self.windPrevision updateFields:@"Viento" :windDesc :[UIImage imageNamed:@"wind"]];
    [self.rainPrev setItems:[NSString stringWithFormat:@"%@ Lm2",rainfall] :[UIImage imageNamed:@"umbrella_drizzle"] ];
    [self.sunrise setItems:sunrise :[UIImage imageNamed:@"sunrise"]];
    [self.sunset setItems:sunset :[UIImage imageNamed:@"sunset"]];
    [self.moonrise setItems:moonrise :[UIImage imageNamed:@"moonrise"]];
    [self.moonset setItems:moonset :[UIImage imageNamed:@"moonset"]];
}
@end
