//
//  SwipeViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "SwipeViewController.h"


@implementation SwipeViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //道路地図レイヤー表示用のマップの作成
    AGSMapView *agsMapView1 = [[AGSMapView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:agsMapView1];
    
    //マップにタイルマップサービスレイヤーを追加（道路地図）
	NSURL *url1 = [NSURL URLWithString:@"https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
	AGSTiledMapServiceLayer *tiledMapServiceLayer1 = [[AGSTiledMapServiceLayer alloc] initWithURL:url1];
	[agsMapView1 addMapLayer:tiledMapServiceLayer1 withName:@"Tiled Layer1"];
    
    AGSEnvelope *envelope = [AGSEnvelope envelopeWithXmin:1.5557970122810215E7 ymin:4258398.013496462 xmax:1.5558175713936899E7  ymax:4258509.895960432  spatialReference:agsMapView1.spatialReference];
    [agsMapView1 zoomToEnvelope:envelope animated:NO];
    
    
    //衛星画像レイヤー表示用のUIViewの作成
    self.layerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.layerView];
    
    //UIViewに衛星画像レイヤー表示用のマップを追加
    AGSMapView *agsMapView2 = [[AGSMapView alloc] initWithFrame:self.view.bounds];
	[self.layerView addSubview:agsMapView2];
    
    //マップにタイルマップサービスレイヤーを追加（衛星画像）
    NSURL *url2 = [NSURL URLWithString:@"https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer"];
	AGSTiledMapServiceLayer *tiledMapServiceLayer2 = [[AGSTiledMapServiceLayer alloc] initWithURL:url2];
	[agsMapView2 addMapLayer:tiledMapServiceLayer2 withName:@"Tiled Layer2"];
    [agsMapView2 zoomToEnvelope:envelope animated:NO];
    
    self.layerView.clipsToBounds = YES;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    slider.minimumValue = 0.0f;
    slider.maximumValue = 1.0f;
    [slider addTarget:self action:@selector(sliderEvent:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    
}

- (void)sliderEvent:(UISlider *)slider {
    
    //衛星画像レイヤー表示用のUIViewのframeを変更する
    [self.layerView setFrame:CGRectMake(0, 0, self.view.frame.size.width * slider.value, self.view.frame.size.height)];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
