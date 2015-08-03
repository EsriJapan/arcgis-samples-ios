//
//  SensorViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "SensorViewController.h"


@implementation SensorViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
	self.agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:self.agsMapView];
    
    //タイルマップサービスレイヤーの追加
    NSURL *url = [NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
    AGSTiledMapServiceLayer *tiledMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    [self.agsMapView addMapLayer:tiledMapServiceLayer withName:@"Tiled Layer"];
    
    //グラフィックスレイヤーの追加
    AGSGraphicsLayer *graphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.agsMapView addMapLayer:graphicsLayer withName:@"Graphics Layer"];
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];

    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations lastObject];

    //CLLocationManagerで取得した現在位置からポイントを作成
    AGSGeometryEngine *agsGeomEngine = [AGSGeometryEngine defaultGeometryEngine];
    AGSPoint *agsPoint = [AGSPoint pointWithX:location.coordinate.longitude y:location.coordinate.latitude spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326]];
    AGSPoint *agsProjectedPoint = (AGSPoint *)[agsGeomEngine projectGeometry:agsPoint toSpatialReference: [AGSSpatialReference spatialReferenceWithWKID:102100]];
    
    //ポイントをグラフィックスレイヤーに追加
    AGSGraphicsLayer *graphicsLayer = (AGSGraphicsLayer *)[self.agsMapView mapLayerForName:@"Graphics Layer"];
    AGSSimpleMarkerSymbol *markerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor blueColor]];
    AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:agsProjectedPoint symbol:markerSymbol attributes:nil];
    [graphicsLayer removeAllGraphics];
    [graphicsLayer addGraphic:graphic];
    
    [self.agsMapView zoomToScale:100000 withCenterPoint:agsProjectedPoint animated:YES];
    
}



- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    if (newHeading.headingAccuracy > 0){
        
        //CLLocationManagerで取得した方位に応じてマップを回転
        [self.agsMapView setRotationAngle:newHeading.magneticHeading];
        
    }
    
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
