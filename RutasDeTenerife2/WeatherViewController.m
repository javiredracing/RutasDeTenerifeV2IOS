//
//  WeatherViewController.m
//  RutasDeTenerife2
//
//  Created by javi on 5/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "WeatherViewController.h"
#import "PrevCell.h"
#import "ForecastCell.h"

@interface WeatherViewController ()

@end

@implementation WeatherViewController{

    int days;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    days = 1;
    // Do any additional setup after loading the view.
    NSLog(@"Wheater view loaded");
    //_responseData = nil;
      NSLog(@"Did load -");
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"view appear");
    NSMutableData *data = [self.route getWeatherJson];
    if (data != nil){
        [self parseJSONData:data];
        NSLog(@"Cached!");
    }else{
        
        NSString *key = @"4dd5f7defe860cc6cb67909a84684a3f50bc160d";
        NSString *lang =  [[NSLocale preferredLanguages] objectAtIndex:0];
        NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:lang];
        NSString *languageCode = [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
        CLLocationCoordinate2D location = [self.route getFirstPoint];
        
        NSString *weatherOnline = [NSString stringWithFormat:@"http://api.worldweatheronline.com/free/v2/weather.ashx?q=%f,%f&format=json&num_of_days=%d&tp=24&key=%@&showlocaltime=yes&lang=%@", location.latitude, location.longitude, days, key, languageCode];
        NSLog(weatherOnline);
        /* http://api.worldweatheronline.com/free/v2/weather.ashx?q="+ myLatLng[0] +","+ myLatLng[1] +"&format=json&num_of_days="+nDays+"&tp=24&key="+getString(R.string.KEY_WEATHER)+"&showlocaltime=yes&lang="+languaje;*/
        
        NSURL *url = [NSURL URLWithString:weatherOnline];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:2.0];
        //http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark NSURLConnection Delegate methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _responseData = [[NSMutableData alloc]init];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_responseData appendData:data];
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    return nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (_responseData != nil) {
        [self parseJSONData:_responseData];
        [self.route setWeatherJson:_responseData];
    }
    NSLog(@"finishing connection");
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Fail connection");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger i = days + 1;
    /*if (_responseData != nil) {
        i = days + 1;
    }*/
    return i;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0){
        PrevCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PrevCell"];
        if (!cell){
            [tableView registerNib:[UINib nibWithNibName:@"PrevCell" bundle:nil] forCellReuseIdentifier:@"PrevCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"PrevCell"];
        }
        NSLog(@"finish cell 0");
        return cell;
    }else{
        ForecastCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ForecastCell"];
        if (!cell){
            [tableView registerNib:[UINib nibWithNibName:@"ForecastCell" bundle:nil] forCellReuseIdentifier:@"ForecastCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"ForecastCell"];
        }
        NSLog(@"finish cell i");
        return cell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat value = 340.0;
    if (indexPath.section == 0)
        value = 350.0;
    return value;
}
/*****************/

-(void)parseJSONData :(NSMutableData *)data{
    NSError *e;
    NSArray *object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    NSLog(@"Object: %@", object);

}

@end
