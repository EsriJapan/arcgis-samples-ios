//
//  WmsViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "WmsViewController.h"

@implementation WmsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AGSMapView *agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:agsMapView];
    
    //WMSレイヤーの追加
    NSURL *wmsUrl = [NSURL URLWithString:@"http://hazardmap.service-section.com/geoserver/wmscapabilities?id=alos_avnir2_chile_santiago_mosaic_20100227"];
    AGSWMSLayer *wmsLayer = [AGSWMSLayer wmsLayerWithURL:wmsUrl];
    [agsMapView addMapLayer:wmsLayer withName:@"WMS Layer"];
    
    //コピーライト用のラベルを追加
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -20 , 70, 20)];
    label.text = @"(c) JAXA";
    label.backgroundColor = [UIColor whiteColor];
    label.alpha = 0.5;
    [self.view addSubview:label];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
