//
//  LocatorViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "LocatorViewController.h"


@implementation LocatorViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.agsMapView];
    self.agsMapView.touchDelegate = self;

    //タイルマップサービスレイヤーの追加
    NSURL *url = [NSURL URLWithString:@"https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
    AGSTiledMapServiceLayer *agsTiledMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    [self.agsMapView addMapLayer:agsTiledMapServiceLayer withName:@"tiledLayer"];
    
    AGSEnvelope *envelope = [AGSEnvelope envelopeWithXmin:1.5557970122810215E7 ymin:4258398.013496462 xmax:1.5558175713936899E7  ymax:4258509.895960432  spatialReference:[AGSSpatialReference spatialReferenceWithWKID:102100]];
    [self.agsMapView zoomToEnvelope:envelope animated:NO];
    
    //住所検索を行うジオコードサービスのURLを設定
    NSURL *geocodeUrl = [NSURL URLWithString: @"https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/"];
    
    //ジオコードサービスのURLを指定して住所検索を行うタスク（AGSLocator）を作成
    self.agsLocator = [[AGSLocator alloc] initWithURL:geocodeUrl];
    
    //AGSLocatorのデリゲートを設定
    self.agsLocator.delegate = self;

}

//マップ上でタップされたときに実行される
-(void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)clickPoint graphics:(NSDictionary *)graphics{
    
    self.agsMapView.callout.hidden = YES;
    self.agsPoint = clickPoint;
    
    //住所を検索する位置をパラメータに指定してタスクを実行
    [self.agsLocator addressForLocation:clickPoint maxSearchDistance:100];
    
}


//住所検索の処理が完了したら実行される
-(void)locator:(AGSLocator *)locator operation:(NSOperation *)op didFindAddressForLocation:(AGSAddressCandidate *)result{
    
    //検索結果から住所の文字列を取得する
    NSString *strAddress = [result.address objectForKey:@"Address"];
    
    //画面に表示するポップアップのタイトルを設定
    self.agsMapView.callout.title = @"住所";
    
    //ポップアップの本文に住所を設定
    self.agsMapView.callout.detail = strAddress;
    
    //最初にマップ上でタップした位置にポップアップを表示
    [self.agsMapView.callout showCalloutAt:self.agsPoint screenOffset:CGPointZero animated:YES];
    
}


-(void)locator:(AGSLocator *)locator operation:(NSOperation *)op didFailAddressForLocation:(NSError *)error{
    
    NSLog(@"Error: %@", error);
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
