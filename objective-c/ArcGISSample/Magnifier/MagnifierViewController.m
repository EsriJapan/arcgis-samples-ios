//
//  MagnifierViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "MagnifierViewController.h"


@implementation MagnifierViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AGSMapView *agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:agsMapView];
    
    //タイルマップサービスレイヤーの追加
    NSURL *url = [NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
    AGSTiledMapServiceLayer *agsTiledMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    [agsMapView addMapLayer:agsTiledMapServiceLayer withName:@"Tiled Layer"];
    
    AGSPoint *point = [AGSPoint pointWithX:15554789.5566484 y:4254781.24130285 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:102100]];
    [agsMapView zoomToScale:100000 withCenterPoint:point animated:YES];

    //マップ上を長押しすると拡大鏡を表示
    agsMapView.showMagnifierOnTapAndHold = YES;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
