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
@property (weak, nonatomic) IBOutlet IconInfoView *rainPrev;
@property (weak, nonatomic) IBOutlet FieldView *windPrevision;
@property (weak, nonatomic) IBOutlet FieldView *prevision;
@property (weak, nonatomic) IBOutlet UILabel *mainDate;
@property (weak, nonatomic) IBOutlet UILabel *mainTitle;

@end
