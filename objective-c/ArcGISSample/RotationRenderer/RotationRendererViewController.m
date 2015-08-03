//
//  RotationRendererViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "RotationRendererViewController.h"

@implementation RotationRendererViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AGSMapView *agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:agsMapView];

    //タイルマップサービスレイヤーの追加
	NSURL *url = [NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
	AGSTiledMapServiceLayer *tiledMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    [agsMapView addMapLayer:tiledMapServiceLayer withName:@"Tiled Layer"];
    
    //シンボル表示用のフィーチャレイヤーの表示
    NSURL *flayerUrl = [NSURL URLWithString:@"http://tmservices1.esri.com/arcgis/rest/services/LiveFeeds/NOAA_METAR_current_wind_speed_direction/MapServer/0"];
    AGSFeatureLayer *flayer = [AGSFeatureLayer featureServiceLayerWithURL:flayerUrl mode:AGSFeatureLayerModeOnDemand];
    flayer.outFields = [NSArray arrayWithObjects: @"WIND_DIRECT", nil];
    [agsMapView addMapLayer:flayer withName:@"Feature Layer"];
    
    //画像ファイルを指定してシンボルとレンダラーを作成
    UIImage *image = [UIImage imageNamed:@"ArcGIS.bundle/LocationDisplayCourse@2x.png"];
    AGSPictureMarkerSymbol *pointSymbol = [[AGSPictureMarkerSymbol alloc] initWithImage:image];
    AGSSimpleRenderer *renderer = [[AGSSimpleRenderer alloc] initWithSymbol:pointSymbol];
    
    //レンダラーの回転角度の値をフィーチャレイヤーの"WIND_DIRECT"フィールドから取得
    renderer.rotationType = AGSRotationTypeGeographic;
    renderer.rotationExpression = @"[WIND_DIRECT]";
    
    //レンダラーをフィーチャレイヤーに適用
    flayer.renderer = renderer;

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
