//
//  ServiceAreaViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "ServiceAreaViewController.h"


@implementation ServiceAreaViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:self.agsMapView];
    
    //タイルマップサービスレイヤーの追加
    NSURL *url = [NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
    AGSTiledMapServiceLayer *tiledMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    [_agsMapView addMapLayer:tiledMapServiceLayer withName:@"Tiled Layer"];
    
    AGSSpatialReference *agsSpRef = [AGSSpatialReference spatialReferenceWithWKID:102100];
    AGSPoint *point = [AGSPoint pointWithX:15554789.5566484 y:4254781.24130285 spatialReference:agsSpRef];
    [self.agsMapView zoomToScale:50000 withCenterPoint:point animated:YES];
    
    //認証の設定:検証用（ArcGIS Onlineのユーザー名とパスワードを指定）
    AGSCredential *credntial = [[AGSCredential alloc] initWithUser:@"<ユーザー名>" password:@"<パスワード>" authenticationType:AGSAuthenticationTypeToken];

    
    //到達圏解析用のサービスURLの指定
    NSURL *saUrl = [NSURL URLWithString:@"https://route.arcgis.com/arcgis/rest/services/World/ServiceAreas/NAServer/ServiceArea_World"];
    self.agsSaTask = [[AGSServiceAreaTask alloc] initWithURL:saUrl credential:credntial];
    self.agsSaTask.delegate = self;
    
    //検索結果の到達圏（ポリゴン）を表示するためのグラフィックスレイヤーを追加
    AGSGraphicsLayer *agsResultsLayer = [AGSGraphicsLayer graphicsLayer];
	[self.agsMapView addMapLayer:agsResultsLayer withName:@"Graphics Layer"];
    
    //解析地点（ポイント）を表示するためのグラフィックスレイヤーを追加
    AGSGraphicsLayer *agsFacilitiesLayer = [AGSGraphicsLayer graphicsLayer];
    [self.agsMapView addMapLayer:agsFacilitiesLayer withName:@"Facilities Layer"];
    
    
    UIBarButtonItem *buttonSolve = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(networkSolve)];
    UIBarButtonItem *buttonClear = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearResults)];
    
    NSArray *buttons = [NSArray arrayWithObjects:buttonSolve, buttonClear, nil];
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
	[toolbar setItems:buttons];	
	[self.view addSubview:toolbar];
    
    //マップの中心にカーソルを表示
    [self drawCenterSign];
    
}


- (void)drawCenterSign {
    
	UIGraphicsBeginImageContext(CGSizeMake(20, 20));
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextSetLineWidth(context, 1.0);
	CGContextMoveToPoint(context, 10, 0);
	CGContextAddLineToPoint(context, 10, 20);
	CGContextMoveToPoint(context, 0, 10);
	CGContextAddLineToPoint(context, 20, 10);
	CGContextStrokePath(context);
	
	CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextSetLineWidth(context, 1.0);
	CGContextMoveToPoint(context, 10, 9);
	CGContextAddLineToPoint(context, 10, 11);
	CGContextMoveToPoint(context, 9, 10);
	CGContextAddLineToPoint(context, 11, 9);
	CGContextStrokePath(context);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	CALayer *caLayer = [CALayer layer];
	caLayer.frame = CGRectMake(_agsMapView.frame.size.width / 2 - 10, _agsMapView.frame.size.height / 2 - 10, 20, 20);
	caLayer.contents = (id)image.CGImage;
	[self.view.layer addSublayer:caLayer];
    
}


- (void)clearResults {

    //グラフィックスレイヤーに追加されたグラフィックを削除
    [(AGSGraphicsLayer *)[self.agsMapView mapLayerForName:@"Graphics Layer"] removeAllGraphics];
    [(AGSGraphicsLayer *)[self.agsMapView mapLayerForName:@"Facilities Layer"] removeAllGraphics];
    
}


- (void)networkSolve {
    
    //解析地点のポイントを作成しグラフィックスレイヤーに追加
    AGSPoint *agsPoint = self.agsMapView.visibleAreaEnvelope.center;
    AGSSimpleMarkerSymbol *agsSym = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    agsSym.color = [UIColor magentaColor];
    agsSym.size = CGSizeMake(12, 12);
    
    AGSGraphic *agsGraphic = [AGSGraphic graphicWithGeometry:agsPoint symbol:agsSym attributes:nil];
    [(AGSGraphicsLayer *)[self.agsMapView mapLayerForName:@"Facilities Layer"] addGraphic:agsGraphic];
    
    
    //到達圏解析用のパラメータを設定
    AGSServiceAreaTaskParameters *agsSaTaskParams = [AGSServiceAreaTaskParameters serviceAreaTaskParameters];

    //解析地点ポイントの配列
    AGSFacilityGraphic *agsFacilityGraphic = [AGSFacilityGraphic graphicWithPoint:agsPoint name:@"Facility Point"];
    NSArray *facilities = [NSArray arrayWithObject:agsFacilityGraphic];
    AGSFeatureSet *agsFeatSet = [AGSFeatureSet featureSetWithFeatures:facilities];
    
    //解析する到達圏（分）の配列
    NSMutableArray *breaks = [[NSMutableArray alloc] init];
    [breaks addObject:[NSNumber numberWithInt:3]];
    [breaks addObject:[NSNumber numberWithInt:5]];
    
    agsSaTaskParams.outSpatialReference = [AGSSpatialReference spatialReferenceWithWKID:102100];
    agsSaTaskParams.facilities = agsFeatSet;
    agsSaTaskParams.returnFacilities = NO;
    agsSaTaskParams.returnPointBarriers = NO;
    agsSaTaskParams.returnPolylineBarriers = NO;
    agsSaTaskParams.returnPolygonBarriers = NO;
    agsSaTaskParams.outputPolygons = AGSNAOutputPolygonSimplified;
    agsSaTaskParams.defaultBreaks = breaks;
    
    //到達圏解析を実行
    [self.agsSaTask solveServiceAreaWithParameters:agsSaTaskParams];
    
}




- (void)serviceAreaTask:(AGSServiceAreaTask *)serviceAreaTask operation:(NSOperation *)op didSolveServiceAreaWithResult:(AGSServiceAreaTaskResult *)serviceAreaTaskResult {
    
    //解析結果のポリゴン（5分の到達圏）にシンボルを設定しグラフィックスレイヤーに追加
    AGSGraphic *agsGraphic1 = [serviceAreaTaskResult.serviceAreaPolygons objectAtIndex:0];
    
    AGSSimpleLineSymbol *agsOutlineSym1 = [AGSSimpleLineSymbol simpleLineSymbol];
    agsOutlineSym1.color = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    agsOutlineSym1.width = 1.5;
    
    AGSSimpleFillSymbol *agsSym1 = [AGSSimpleFillSymbol simpleFillSymbol];
    agsSym1.color = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.5];
    agsSym1.style = AGSSimpleFillSymbolStyleSolid;
    agsSym1.outline = agsOutlineSym1;

    agsGraphic1.symbol = agsSym1;
    [(AGSGraphicsLayer *)[self.agsMapView mapLayerForName:@"Graphics Layer"] addGraphic:agsGraphic1];
    
    
    //解析結果のポリゴン（3分の到達圏）にシンボルを設定しグラフィックスレイヤーに追加
    AGSGraphic *agsGraphic2 = [serviceAreaTaskResult.serviceAreaPolygons objectAtIndex:1];
    
    AGSSimpleLineSymbol *agsOutlineSym2 = [AGSSimpleLineSymbol simpleLineSymbol];
    agsOutlineSym2.color = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    agsOutlineSym2.width = 1.5;
    
    AGSSimpleFillSymbol *agsSym2 = [AGSSimpleFillSymbol simpleFillSymbol];
    agsSym2.color = [UIColor colorWithRed:0 green:0 blue:1.0 alpha:0.5];
    agsSym2.style = AGSSimpleFillSymbolStyleSolid;
    agsSym2.outline = agsOutlineSym2;
    
    agsGraphic2.symbol = agsSym2;
    [(AGSGraphicsLayer *)[self.agsMapView mapLayerForName:@"Graphics Layer"] addGraphic:agsGraphic2];
    
    
    //解析結果のポリゴン（5分の到達圏）にズーム
    AGSPolygon *agsPolygon = (AGSPolygon *)agsGraphic1.geometry;
    [self.agsMapView zoomToEnvelope:agsPolygon.envelope animated:YES];
    
}


- (void)serviceAreaTask:(AGSServiceAreaTask *)serviceAreaTask operation:(NSOperation *)op didFailSolveWithError:(NSError *)error {
    
    //到達圏解析の処理に失敗した場合にエラー内容を表示
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"到達圏を検索できませんでした。" message:[NSString stringWithFormat:@"Error:%@", error] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
