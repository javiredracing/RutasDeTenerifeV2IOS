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
#import "Toast/UIView+Toast.h"

@interface WeatherViewController ()

@end

@implementation WeatherViewController{

    int days;
    NSDictionary *weatherData;
    NSString *languageCode;
    NSString *countryCode;
    BOOL firstTime;
    UIColor *lightGreenColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *startGray = [UIColor colorWithRed:(204.0 / 255.0) green:(202.0 / 255.0) blue:(202.0 / 255.0) alpha:1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [self.view bounds];
    gradient.colors = [NSArray arrayWithObjects:(id)[startGray CGColor], (id)[[UIColor lightGrayColor] CGColor], nil];
    gradient.startPoint = CGPointZero;
    gradient.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:gradient atIndex:0];

    days = 1;
    lightGreenColor = [UIColor colorWithRed:(187.0 / 255.0) green:(234.0 / 255.0) blue:(176.0 / 255.0) alpha:1.0];
    self.nextDaysBtn.layer.borderColor = lightGreenColor.CGColor;
    self.nextDaysBtn.layer.shadowColor = [UIColor grayColor].CGColor;
    self.nextDaysBtn.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.nextDaysBtn.layer.shadowOpacity = 0.8;
    self.nextDaysBtn.layer.shadowRadius = 5.0;
    if (days != 1){
        self.nextDaysBtn.hidden = YES;
    }
    
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    firstTime = true;
    // Do any additional setup after loading the view.
    //NSLog([NSString stringWithFormat:@"Country code: %@",countryCode ]);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSMutableData *data = [self.route getWeatherJson];
    if ((firstTime) || (data == nil)){
        NSLog(@"view appear");
        firstTime = false;
        NSString *lang =  [[NSLocale preferredLanguages] objectAtIndex:0];
        NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:lang];
        languageCode = [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
        if (data != nil){
            [self parseJSONData:data];
            NSLog(@"Cached!");
        }else{
            NSString *key = @"4dd5f7defe860cc6cb67909a84684a3f50bc160d";
            CLLocationCoordinate2D location = [self.route getFirstPoint];
            
            NSString *weatherOnline = [NSString stringWithFormat:@"http://api.worldweatheronline.com/free/v2/weather.ashx?q=%f,%f&format=json&num_of_days=%d&tp=24&key=%@&showlocaltime=yes&lang=%@", location.latitude, location.longitude, days, key, languageCode];
            NSLog(weatherOnline);
            NSURL *url = [NSURL URLWithString:weatherOnline];
            [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:2.0];
            //http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
            NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    NSLog(@"finishing connection");
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Fail connection");
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    [self.view makeToast:NSLocalizedString(@"fail_connection", @"") duration:2.0 position:CSToastPositionCenter];
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
            cell.layer.borderColor = lightGreenColor.CGColor;
            //NSLog([NSString stringWithFormat:@"loaded cell %ld",(long)indexPath.section]);
        }
        if (weatherData != nil) {

            NSArray *time_zone = [weatherData objectForKey:@"time_zone"];
            NSDictionary *time = [time_zone objectAtIndex:0];
            NSString *localtime = [time objectForKey:@"localtime"];

            NSArray *currentConditions = [weatherData objectForKey:@"current_condition"];
            NSDictionary *condition = [currentConditions objectAtIndex:0];
            //NSString *tempC = [condition objectForKey:@"temp_C"];
            NSString *currentDesc = @"";
            NSArray *lang_XX = [condition objectForKey:[NSString stringWithFormat:@"lang_%@",languageCode]];
            if (lang_XX != nil){
                NSDictionary *desc = [lang_XX objectAtIndex:0];
                currentDesc = [desc objectForKey:@"value"];
            }else{
                NSArray *weatherDesc = [condition objectForKey:@"weatherDesc"];
                NSDictionary *desc = [weatherDesc objectAtIndex:0];
                currentDesc = [desc objectForKey:@"value"];
            }
            
            NSString *windSpeed =@"";
            if ([countryCode isEqualToString:@"UK"] || [countryCode isEqualToString:@"US"]){
                windSpeed = [condition objectForKey:@"windspeedMiles"];
            }else
                windSpeed = [condition objectForKey:@"windspeedKmph"];
            
            NSString *temperature = @"";
            if ([countryCode isEqualToString:@"US"]) {
                temperature =[condition objectForKey:@"temp_F"];
            }else
                temperature =[condition objectForKey:@"temp_C"];
            
            //(NSString*)hour :(NSString *)iconCode :(NSString*)temperature :(NSString *)description :(NSString *)wind :(NSString *)cloudly :(NSString *)humidity :(NSString *)pressure :(NSString *)rainfall;
            [cell setCurrentCond:localtime :[condition objectForKey:@"weatherCode"] : temperature:currentDesc :windSpeed :[condition objectForKey:@"winddir16Point"] :[condition objectForKey:@"cloudcover"] :[condition objectForKey:@"humidity"] :[condition objectForKey:@"pressure"] :[condition objectForKey:@"precipMM"] :countryCode];
        }
        //NSLog([NSString stringWithFormat:@"loaded cell %ld",(long)indexPath.section]);
        return cell;
    }else{
        ForecastCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ForecastCell"];
        if (!cell){
            [tableView registerNib:[UINib nibWithNibName:@"ForecastCell" bundle:nil] forCellReuseIdentifier:@"ForecastCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"ForecastCell"];
            cell.layer.borderColor = lightGreenColor.CGColor;
        }
        if (weatherData != nil) {
            
            NSArray *weather = [weatherData objectForKey:@"weather"];
            NSDictionary *forecast = [weather objectAtIndex:(indexPath.section - 1)];
            
            NSArray *hourly = [forecast objectForKey:@"hourly"];
            NSDictionary *hourly_weather = [hourly objectAtIndex:0];
            
            /**Description**/
            NSString *currentDesc = @"";
            NSArray *lang_XX = [hourly_weather objectForKey:[NSString stringWithFormat:@"lang_%@",languageCode]];
            if (lang_XX != nil){
                NSDictionary *desc = [lang_XX objectAtIndex:0];
                currentDesc = [desc objectForKey:@"value"];
            }else{
                NSArray *weatherDesc = [hourly_weather objectForKey:@"weatherDesc"];
                NSDictionary *valueDesc = [weatherDesc objectAtIndex:0];
                currentDesc = [valueDesc objectForKey:@"value"];
            }
            
            NSArray *astronomy = [forecast objectForKey:@"astronomy"];
            NSDictionary *moonSun = [astronomy objectAtIndex:0];
            
            NSString *windSpeed =@"";
            if ([countryCode isEqualToString:@"UK"] || [countryCode isEqualToString:@"US"]){
                windSpeed = [hourly_weather objectForKey:@"windspeedMiles"];
            }else
                windSpeed = [hourly_weather objectForKey:@"windspeedKmph"];
            
            NSString *temperatureMax = @"";
            NSString *temperatureMin = @"";
            if ([countryCode isEqualToString:@"US"]) {
                temperatureMax =[forecast objectForKey:@"maxtempF"];
                temperatureMin =[forecast objectForKey:@"mintempF"];
            }else{
                temperatureMax =[forecast objectForKey:@"maxtempC"];
                temperatureMin = [forecast objectForKey:@"mintempC"];
            }

           // (NSString *)date :(NSString *)maxTemp :(NSString *)minTemp :(NSString *)description :(NSString*) iconCode :(NSString *)windSpeed :(NSString *)windDirec :(NSString *)rainfall :(NSString *)sunset :(NSString *)sunrise :(NSString * )moonset :(NSString *)moonrise;
            [cell setForecast:[forecast objectForKey:@"date"]:temperatureMax :temperatureMin:currentDesc :[hourly_weather objectForKey:@"weatherCode"] :windSpeed :[hourly_weather objectForKey:@"winddir16Point"] :[hourly_weather objectForKey:@"precipMM"] :[moonSun objectForKey:@"sunset"] :[moonSun objectForKey:@"sunrise"] :[moonSun objectForKey:@"moonset"] :[moonSun objectForKey:@"moonrise"] :countryCode];
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
    if (parsedJSON != nil){
        weatherData = [parsedJSON objectForKey:@"data"];
        [self.weatherTableView reloadData]; //Reload tableview when all data have been parsed correctly
    }
}

- (IBAction)nextDaysTap:(UIButton *)sender {
    //TODO deploy view
    if (days == 1){
        [self showPremiumDialog];
    }
}
-(void)showPremiumDialog{
 
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    
    //TODO add internal margins to uilabel
    UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 290, 250)];
    lbl1.textColor = [UIColor grayColor];
    lbl1.backgroundColor=[UIColor clearColor];
    lbl1.userInteractionEnabled = NO;
    lbl1.numberOfLines = 0;
    lbl1.clipsToBounds = YES;
    lbl1.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    lbl1.text= NSLocalizedString(@"help_me", @"");
    
    [alertView setContainerView:lbl1];
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"cancel", @""), NSLocalizedString(@"collaborate", @""), nil, nil]];
    
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        [alertView close];
    }];
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];
    
}
@end
