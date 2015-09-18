//
//  WebmapViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "WebmapViewController.h"


@implementation WebmapViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //Webマップを表示するマップの作成
    AGSMapView *agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:agsMapView];
    
    //組織のArcGIS OnlineのURLとWebマップのIDを指定して、Webマップを作成
    NSURL *portalUrl = [NSURL URLWithString:@"https://ej.maps.arcgis.com/sharing"];
    self.webmap = [[AGSWebMap alloc] initWithItemId:@"d2dacbb4215d44da903a73c245bdce67" sharingEndPoint:portalUrl credential:nil];
    
    self.webmap.delegate = self;
    
    //Webマップを開く
    [self.webmap openIntoMapView:agsMapView];
    
}


- (void)didOpenWebMap:(AGSWebMap *)webMap intoMapView:(AGSMapView *)mapView {
    
    //Webマップの読み込み
    NSLog(@"didOpenWebMap: %f", webMap.version);
    
}

- (void)didLoadLayer:(AGSLayer *)layer {
    
    //Webマップに含まれるレイヤの読み込み
    NSLog(@"didLoadLayer: %@", layer.name);
    
}

- (void)didFailToLoadLayer:(NSString *)layerTitle withError:(NSError *)error {
    
    //Webマップの読み込み失敗
    NSLog(@"%@", [error localizedDescription]);
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
