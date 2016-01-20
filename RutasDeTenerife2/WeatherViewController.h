//
//  WeatherViewController.h
//  RutasDeTenerife2
//
//  Created by javi on 5/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

//#import "ViewController.h"
#import "Route.h"

@interface WeatherViewController : UIViewController<NSURLConnectionDataDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableData *_responseData;
    
}
@property (weak, nonatomic) IBOutlet UITableView *weatherTableView;

@property Route *route;

@end
