//
//  TimeViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "TimeViewController.h"


@implementation TimeViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:self.agsMapView];
    
    //タイルマップサービスレイヤーの追加
    NSURL *url = [NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer"];
    AGSTiledMapServiceLayer *tiledMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    [self.agsMapView addMapLayer:tiledMapServiceLayer withName:@"Tiled Layer"];

    //時間対応レイヤー表示用のフィーチャレイヤーの追加
    NSURL *timeUrl = [NSURL URLWithString:@"http://sampleserver3.arcgisonline.com/ArcGIS/rest/services/Hurricanes/NOAA_Tracks_1851_2007/MapServer/0"];
    AGSFeatureLayer *agsFeatureLayer = [[AGSFeatureLayer alloc] initWithURL:timeUrl mode:AGSFeatureLayerModeOnDemand];
	[self.agsMapView addMapLayer:agsFeatureLayer withName:@"Time Layer"];
    
    //マップ上でフィーチャを表示する時間範囲を指定
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    self.startDate = [dateFormatter dateFromString:@"1900-1-1"];
    self.endDate = [dateFormatter dateFromString:@"1901-1-1"];
    
    AGSTimeExtent *agsTimeExtent = [[AGSTimeExtent alloc] initWithStart:self.startDate end:self.endDate];
    self.agsMapView.timeExtent = agsTimeExtent;
    
    
    UIBarButtonItem *timeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(buttonEvent:)];
    self.navigationItem.rightBarButtonItem = timeItem;
    
}


- (void)buttonEvent:(UIButton *)button {
    
    //マップ上でフィーチャを表示する時間範囲を1年単位で変更
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.year = 1;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *startDateNew = [calendar dateByAddingComponents:comps toDate:self.startDate options:0];
    NSDate *endDateNew = [calendar dateByAddingComponents:comps toDate:self.endDate options:0];
    
    self.startDate = startDateNew;
    self.endDate = endDateNew;
    
    NSLog(@"Start:%@, End:%@", [self.startDate description], [self.endDate description]);
    
    AGSTimeExtent *agsTimeExtent = [[AGSTimeExtent alloc] initWithStart:self.startDate end:self.endDate];
    self.agsMapView.timeExtent = agsTimeExtent;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
