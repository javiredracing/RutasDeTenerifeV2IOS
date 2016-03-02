//
//  ForecastCell.h
//  RutasDeTenerife2
//
//  Created by javi on 12/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FieldView.h"
#import "IconInfoView.h"

@interface ForecastCell : UITableViewCell

@property (weak, nonatomic) IBOutlet IconInfoView *moonset;
@property (weak, nonatomic) IBOutlet IconInfoView *moonrise;
@property (weak, nonatomic) IBOutlet IconInfoView *sunset;
@property (weak, nonatomic) IBOutlet IconInfoView *sunrise;
@property (weak, nonatomic) IBOutlet IconInfoView *rainPrev;
@property (weak, nonatomic) IBOutlet FieldView *windPrevision;
@property (weak, nonatomic) IBOutlet FieldView *prevision;
@property (weak, nonatomic) IBOutlet UILabel *mainDate;
@property (weak, nonatomic) IBOutlet UILabel *mainTitle;

-(void)setForecast:(NSString *)date :(NSString *)maxTemp :(NSString *)minTemp :(NSString *)description :(NSString*) iconCode :(NSString *)windSpeed :(NSString *)windDirec :(NSString *)rainfall :(NSString *)sunset :(NSString *)sunrise :(NSString * )moonset :(NSString *)moonrise :(NSString *)countryCode
;

@end
