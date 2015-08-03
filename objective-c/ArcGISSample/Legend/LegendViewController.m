//
//  LegendViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "LegendViewController.h"


@implementation LegendViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    [self.agsMapView enableWrapAround];
    [self.view addSubview:self.agsMapView];
    
    //タイルマップサービスレイヤーの追加
    NSURL *url = [NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
    AGSTiledMapServiceLayer *agsTiledMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    [self.agsMapView addMapLayer:agsTiledMapServiceLayer withName:@"Tiled layer"];
    
    //凡例用のダイナミックマップサービスレイヤーの追加
	NSURL *dynamicLayerUrl = [NSURL URLWithString:@"http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Specialty/ESRI_StateCityHighway_USA/MapServer"];
    AGSDynamicMapServiceLayer *agsDynamicMapServiceLayer = [[AGSDynamicMapServiceLayer alloc] initWithURL:dynamicLayerUrl];
    [self.agsMapView addMapLayer:agsDynamicMapServiceLayer withName:@"Legend Layer"];
    
    agsDynamicMapServiceLayer.delegate = self;

    
}


- (void) layerDidLoad:(AGSLayer*) layer{

    if ([layer.name isEqualToString:@"Legend Layer"]) {
        
        [self.agsMapView zoomToEnvelope:layer.initialEnvelope animated:YES];
        
        //ダイナミックマップサービスレイヤーの表示設定（ID:2のレイヤを表示）
        AGSDynamicMapServiceLayer *dlayer = (AGSDynamicMapServiceLayer *)layer;
        dlayer.visibleLayers = @[@2];
        
        //ダイナミックマップサービスレイヤーの凡例情報の取得
        AGSMapServiceInfo *agsMapServiceInfo = dlayer.mapServiceInfo;
        agsMapServiceInfo.delegate = self;
        [agsMapServiceInfo retrieveLegendInfo];
        
        NSLog(@"%@", agsMapServiceInfo.serviceDescription);
        
    }
    
}


- (void)mapServiceInfo:(AGSMapServiceInfo *)mapServiceInfo operationDidRetrieveLegendInfo:(NSOperation *)op {
    
    
    UIScrollView *legendView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 100, 150, 200)];
    legendView.backgroundColor = [UIColor whiteColor];
    legendView.alpha = 0.8;
    [[legendView layer] setCornerRadius:10.0];
    

    double y = 10;

    //ID:2の凡例情報を取得
    AGSMapServiceLayerInfo *layerInfo = [mapServiceInfo.layerInfos objectAtIndex:2];
    
    for(int i=0; i<layerInfo.legendImages.count; i++){
        
        //各凡例の画像とラベルを取得
        UIImage *legendImage = [layerInfo.legendImages objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:legendImage];
        imageView.frame = CGRectMake(10, y, legendImage.size.width, legendImage.size.height);
        [legendView addSubview:imageView];
            
        UILabel *legendlabel = [[UILabel alloc] initWithFrame:CGRectMake(legendImage.size.width + 15, y, 100, legendImage.size.height)];
        legendlabel.font = [UIFont boldSystemFontOfSize:10];
        legendlabel.textColor = [UIColor blackColor];
        legendlabel.text = [layerInfo.legendLabels objectAtIndex:i];
        [legendView addSubview:legendlabel];

        y += legendImage.size.height;
            
    }
    
    legendView.contentSize = CGSizeMake(150, y);
    [self.view addSubview:legendView];
    
}


- (void)mapServiceInfo:(AGSMapServiceInfo *)mapServiceInfo operation:(NSOperation *)op didFailToRetrieveLegendInfoWithError:(NSError *)error {
    
    NSLog(@"Error: %@", error);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
