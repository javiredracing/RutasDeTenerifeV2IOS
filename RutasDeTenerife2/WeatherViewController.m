//
//  WeatherViewController.m
//  RutasDeTenerife2
//
//  Created by javi on 5/1/16.
//  Copyright © 2016 JAVI. All rights reserved.
//

#import "WeatherViewController.h"

@interface WeatherViewController ()

@end

@implementation WeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"Wheater view loaded");
    
    NSMutableData *data = [self.route getWeatherJson];
    if (data != nil){
        [self parseJSONData:data];
        NSLog(@"Cached!");
    }else{
        int days = 1;
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

/*****************/

-(void)parseJSONData :(NSMutableData *)data{
    NSError *e;
    NSArray *object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    NSLog(@"Object: %@", object);

}

@end
