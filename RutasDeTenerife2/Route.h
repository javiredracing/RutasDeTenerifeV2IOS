//
//  Route.h
//  RutasDeTenerife
//
//  Created by javi on 30/10/15.
//  Copyright © 2015 JAVI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Route : NSObject{

    NSMutableArray *markerList;
    NSString *name;
    NSString *xmlRoute;
    BOOL isActive;
    double dist;
    int difficulty;
    int identifier;
    double durac;
    NSMutableData *weatherJson;
    NSTimeInterval timeStamp;
    int region;
    int approved;
    BOOL isVisible;
}

@property BOOL isActive;

-(void)setMarker: (MKPointAnnotation *) marker;
-(NSString *)getName;
-(NSString *)getXmlRoute;
-(double)getDist;
-(double)getDurac;
-(int)getDifficulty;
-(int)getId;
-(CLLocationCoordinate2D)getFirstPoint;
-(void)setMarkersVisibility: (NSInteger)dist : (NSInteger)dif :(NSInteger)durac;
-(void)setMarkerVisibilityTrue;
-(void)setWeatherJson:(NSMutableData *)json;
-(NSMutableData *)getWeatherJson;
-(void)clearWeather;
-(int)getRegion;
-(int)approved;
-(NSMutableArray *)getMarkersList;
-(id)init:(int)_id :(NSString *) name1 :(NSString*)_xml :(double)_dist :(int) _difficulty : (double)_durac :(int)_approved :(int)reg;
-(BOOL)isVisible;

@end
