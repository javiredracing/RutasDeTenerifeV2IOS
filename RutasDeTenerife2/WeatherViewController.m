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
    NSDictionary *weatherData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    days = 3;
    // Do any additional setup after loading the view.
    NSLog(@"Wheater view loaded");
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
        if (weatherData != nil) {
            //NSLog(@"WeatherData NOT NIL");
            NSArray *time_zone = [weatherData objectForKey:@"time_zone"];
            NSDictionary *time = [time_zone objectAtIndex:0];
            NSString *localtime = [time objectForKey:@"localtime"];
           // NSLog(localtime);
            NSArray *currentConditions = [weatherData objectForKey:@"current_condition"];
            NSDictionary *condition = [currentConditions objectAtIndex:0];
            //NSString *tempC = [condition objectForKey:@"temp_C"];
            NSArray *weatherDesc = [condition objectForKey:@"weatherDesc"];
            NSDictionary *desc = [weatherDesc objectAtIndex:0];
            NSString *currentDesc = [desc objectForKey:@"value"];
            //(NSString*)hour :(NSString *)iconCode :(NSString*)temperature :(NSString *)description :(NSString *)wind :(NSString *)cloudly :(NSString *)humidity :(NSString *)pressure :(NSString *)rainfall;
            [cell setCurrentCond:localtime :[condition objectForKey:@"weatherCode"] :[condition objectForKey:@"temp_C"] :currentDesc :[condition objectForKey:@"windspeedKmph"] :[condition objectForKey:@"cloudcover"] :[condition objectForKey:@"humidity"] :[condition objectForKey:@"pressure"] :[condition objectForKey:@"precipMM"]];
        }
        //NSLog([NSString stringWithFormat:@"loaded cell %ld",(long)indexPath.section]);
        return cell;
    }else{
        ForecastCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ForecastCell"];
        if (!cell){
            [tableView registerNib:[UINib nibWithNibName:@"ForecastCell" bundle:nil] forCellReuseIdentifier:@"ForecastCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"ForecastCell"];
        }
        if (weatherData != nil) {
            
            NSArray *weather = [weatherData objectForKey:@"weather"];
            NSDictionary *forecast = [weather objectAtIndex:(indexPath.section - 1)];
            
            NSArray *hourly = [forecast objectForKey:@"hourly"];
            NSDictionary *hourly_weather = [hourly objectAtIndex:0];
            
            NSArray *weatherDesc = [hourly_weather objectForKey:@"weatherDesc"];
            NSDictionary *valueDesc = [weatherDesc objectAtIndex:0];
            NSString *desc = [valueDesc objectForKey:@"value"];
            
            NSArray *astronomy = [forecast objectForKey:@"astronomy"];
            NSDictionary *moonSun = [astronomy objectAtIndex:0];
            
           // (NSString *)date :(NSString *)maxTemp :(NSString *)minTemp :(NSString *)description :(NSString*) iconCode :(NSString *)windSpeed :(NSString *)windDirec :(NSString *)rainfall :(NSString *)sunset :(NSString *)sunrise :(NSString * )moonset :(NSString *)moonrise;
            [cell setForecast:[forecast objectForKey:@"date"]:[forecast objectForKey:@"maxtempC"] :[forecast objectForKey:@"mintempC"]:desc :[hourly_weather objectForKey:@"weatherCode"] :[hourly_weather objectForKey:@"windspeedKmph"] :[hourly_weather objectForKey:@"winddir16Point"] :[hourly_weather objectForKey:@"precipMM"] :[moonSun objectForKey:@"sunset"] :[moonSun objectForKey:@"sunrise"] :[moonSun objectForKey:@"moonset"] :[moonSun objectForKey:@"moonrise"] ];
        }
        //NSLog([NSString stringWithFormat:@"loaded cell %ld",(long)indexPath.section]);
        return cell;
    }
}

/*-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    NSLog([NSString stringWithFormat:@"Display cell %ld",(long)indexPath.row]);
}*/

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat value = 340.0;
    if (indexPath.section == 0)
        value = 350.0;
    return value;
}
/*****************/

-(void)parseJSONData :(NSMutableData *)data{
    NSError *e;
    NSDictionary *parsedJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    weatherData = [parsedJSON objectForKey:@"data"];
    [self.weatherTableView reloadData];
}

@end
