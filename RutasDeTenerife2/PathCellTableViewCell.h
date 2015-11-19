//
//  PathCellTableViewCell.h
//  RutasDeTenerife2
//
//  Created by javi on 19/11/15.
//  Copyright © 2015 JAVI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PathCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dificultImage;
@property (weak, nonatomic) IBOutlet UILabel *title;

@end
