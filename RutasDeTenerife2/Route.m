//
//  Route.m
//  RutasDeTenerife
//
//  Created by javi on 30/10/15.
//  Copyright © 2015 JAVI. All rights reserved.
//

#import "Route.h"

@implementation Route

@synthesize isActive = _isActive;


-(id)init:(int)_id :(NSString *) name1 :(NSString*)_xml :(double)_dist :(int) _difficulty : (double)_durac :(int)_approved :(int)reg{
    self = [super init];
    if (self) {
        //self
        markerList = [[NSMutableArray alloc]init];
        name = name1;
        xmlRoute = _xml;
        dist = _dist;
        difficulty = _difficulty;
        identifier = _id;
        durac = _durac;
        timeStamp = 0;
        weatherJson = nil;
        region = reg;
        approved = _approved;
        isVisible = YES;
    }
    return self;
}

/*-(void)setMarker:(GMSMarker *)marker{
 
}*/
-(void)setMarker: (MKPointAnnotation *) marker{
    [markerList addObject:marker];
}

-(NSString *)getName{
    return name;
}

-(NSString *)getXmlRoute{
    return xmlRoute;
}

-(double)getDist{
    return dist;
}

-(double)getDurac{
    return durac;
}

-(int)getDifficulty{
    return difficulty;
}

-(int)getId{
    return identifier;
}

-(BOOL)isVisible{
    return isVisible;
}

-(CLLocationCoordinate2D)getFirstPoint{
    MKPointAnnotation *marker = [markerList objectAtIndex:0];
    CLLocationCoordinate2D pos = [marker coordinate];
    return pos;
}

-(void)setMarkersVisibility:(NSInteger)distValue :(NSInteger)difValue :(NSInteger)duracValue{

    BOOL lonCond = NO;
    BOOL difCond = NO;
    BOOL duracCond = NO;
    
    switch (distValue) {
        case 0:
            lonCond = YES;
            break;
        case 1:
            if (dist < 11){
                lonCond = YES;
            }
            break;
        case 2:
            if ((dist >= 11) && (dist < 50)){
                lonCond = YES;
            }
            break;
            
        default:
            if (dist >= 50){
                lonCond = YES;
            }
            break;
    }
    
    switch (difValue) {
        case 0:
            difCond = YES;
            break;
        case 1:
            if (difficulty == 1){
                difCond = YES;
            }
            break;
        case 2:
            if (difficulty == 2){
                difCond = YES;
            }
            break;
        case 3:
            if (difficulty == 3) {
                difCond = YES;
            }
            break;
            
        default:
            if (difficulty > 3){
                difCond = YES;
            }
            break;
    }
    
    switch (duracValue) {
        case 0:
            duracCond = YES;
            break;
        case 1:
            if (durac < 2) {
                duracCond = YES;
            }
            break;
        case 2:
            if ((durac >= 2) && (durac < 6)){
                duracCond = YES;
            }
            break;
        case 3:
            if (durac >= 6) {
                duracCond = YES;
            }
            break;
        default:
            duracCond = YES;
            break;
    }
    
    isVisible = (lonCond && difCond && duracCond);
}

-(void)setMarkerVisibilityTrue{
    isVisible = YES;
}

-(void)setWeatherJson:(NSMutableData *)json{
    weatherJson = json;
    timeStamp =[[NSDate date] timeIntervalSince1970];
}

-(NSMutableData *)getWeatherJson{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (weatherJson != nil){
        if (now - timeStamp <= 3600)
            return weatherJson;
        else
            [self clearWeather];
    }
    return nil;
}

-(void)clearWeather{
    weatherJson = nil;
    timeStamp = 0.0;
}

-(int)getRegion{
    return region;
}

-(int)approved{
    return approved;
}

-(NSMutableArray *)getMarkersList{
    return markerList;
}

@end
