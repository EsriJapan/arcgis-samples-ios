//
//  LayersViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "LayersViewController.h"


@implementation LayersViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    [self.agsMapView enableWrapAround];
	[self.view addSubview:self.agsMapView];
    
    //タイルマップサービスレイヤーの追加（衛星画像）
	NSURL *url1 = [NSURL URLWithString:@"https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer"];
	AGSTiledMapServiceLayer *tiledMapServiceLayer1 = [[AGSTiledMapServiceLayer alloc] initWithURL:url1];
	[self.agsMapView addMapLayer:tiledMapServiceLayer1 withName:@"World_Imagery"];

    //タイルマップサービスレイヤーの追加（道路地図）
    NSURL *url2 = [NSURL URLWithString:@"https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
	AGSTiledMapServiceLayer *tiledMapServiceLayer2 = [[AGSTiledMapServiceLayer alloc] initWithURL:url2];
    [self.agsMapView addMapLayer:tiledMapServiceLayer2 withName:@"World_Street_Map"];

    
    UISwitch *switch1 = [[UISwitch alloc] initWithFrame:CGRectMake(20, 90, 20, 20)];
    switch1.tag = 1;
    switch1.on = YES;
    [switch1 addTarget:self action:@selector(switchEvent:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:switch1];
    
    UISwitch *switch2 = [[UISwitch alloc] initWithFrame:CGRectMake(20, 130, 20, 20)];
    switch2.tag = 2;
    switch2.on = YES;
    [switch2 addTarget:self action:@selector(switchEvent:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:switch2];
    
}

- (void)switchEvent:(id)sender {

    
    //衛星画像・道路地図レイヤーの表示・非表示
    UISwitch *sw = sender;
    
    if (sw.tag == 1) {

        if (sw.on) {
            [self.agsMapView mapLayerForName:@"World_Street_Map"].visible = YES;
        } else {
            [self.agsMapView mapLayerForName:@"World_Street_Map"].visible = NO;
        }
        
    } else if (sw.tag == 2) {
        
        if (sw.on) {
            [self.agsMapView mapLayerForName:@"World_Imagery"].visible = YES;
        } else {
            [self.agsMapView mapLayerForName:@"World_Imagery"].visible = NO;
        }
        
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end