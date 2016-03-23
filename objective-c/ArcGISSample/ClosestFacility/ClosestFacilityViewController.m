//
//  ClosestFacilityViewController.m
//
//  Created by ej2047 on 11/07/07.
//

#import "ClosestFacilityViewController.h"

@implementation ClosestFacilityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.agsMapView];
    
    // タイルマップ サービス レイヤの追加
    NSURL *url = [NSURL URLWithString:@"https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
    AGSTiledMapServiceLayer *tiledMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    [_agsMapView addMapLayer:tiledMapServiceLayer withName:@"Tiled Layer"];
    
    // フィーチャ サービス レイヤの追加（ESRIジャパン オープンデータポータルより「学校 教育施設 文化教養施設」を使用）
    NSURL *featureLayerUrl = [NSURL URLWithString:@"https://services3.arcgis.com/iH4Iz7CEdh5xTJYb/arcgis/rest/services/Itabashi_ku_Gakko/FeatureServer/0"];
    
    self.agsFeatureLayer = [[AGSFeatureLayer alloc] initWithURL:featureLayerUrl mode:AGSFeatureLayerModeOnDemand];
    self.agsFeatureLayer.outFields = @[@"*"];
    [self.agsMapView addMapLayer:self.agsFeatureLayer withName:@"Feature Layer"];
    
    // 最寄り施設検索結果表示用のグラフィックス レイヤ
    AGSGraphicsLayer *agsResultsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.agsMapView addMapLayer:agsResultsLayer withName:@"Graphics Layer"];
    
    // 地図の初期表示範囲の指定
    AGSPoint *point = [AGSPoint pointWithX:139.679096 y:35.765221 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:4326]];
    [self.agsMapView zoomToScale:100000 withCenterPoint:point animated:YES];
    
    // 認証（ArcGIS Online 組織向けプランでログイン）
    // ユーザーアカウントとパスワードを入力してください
    AGSCredential *credntial = [[AGSCredential alloc] initWithUser:@"ユーザー" password:@"パスワード" authenticationType:AGSAuthenticationTypeToken];
    
    // 最寄り施設解析用のサービスを指定
    NSURL *cfUrl = [NSURL URLWithString:@"https://route.arcgis.com/arcgis/rest/services/World/ClosestFacility/NAServer/ClosestFacility_World"];
    
    self.agsCfTask = [[AGSClosestFacilityTask alloc] initWithURL:cfUrl credential:credntial];
    self.agsCfTask.delegate = self;
    
    // UI の要素作成
    UIBarButtonItem *buttonSolve = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(networkSolve)];
    UIBarButtonItem *buttonClear = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearResults)];
    
    NSArray *buttons = [NSArray arrayWithObjects:buttonSolve, buttonClear, nil];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    [toolbar setItems:buttons];
    [self.view addSubview:toolbar];
    
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
    
    [(AGSGraphicsLayer *)[self.agsMapView mapLayerForName:@"Graphics Layer"] removeAllGraphics];
    
}


- (void)networkSolve {
    
    
    AGSClosestFacilityTaskParameters *agsCfTaskParams = [AGSClosestFacilityTaskParameters closestFacilityTaskParameters];
    
    // 最寄り施設検索のためのパラメータを設定する
    agsCfTaskParams.outSpatialReference = [AGSSpatialReference spatialReferenceWithWKID:102100];
    agsCfTaskParams.returnRouteGraphics = YES;
    agsCfTaskParams.defaultTargetFacilityCount = 3;
    agsCfTaskParams.travelDirection = AGSNATravelDirectionFromFacility;
    agsCfTaskParams.impedanceAttributeName = @"Minutes";
    agsCfTaskParams.defaultCutoffValue = 20;
    
    // 最寄施設検索を実行
    AGSPoint *agsPointIncident = self.agsMapView.visibleAreaEnvelope.center;
    AGSGeometryEngine *agsGeomEngine = [AGSGeometryEngine defaultGeometryEngine];
    AGSPoint *agsPointWeb = (AGSPoint *)[agsGeomEngine projectGeometry:agsPointIncident toSpatialReference:[AGSSpatialReference spatialReferenceWithWKID:102100]];
    AGSGraphic *agsGraphicIncident = [[AGSGraphic alloc] initWithGeometry:agsPointWeb symbol:nil attributes:nil];
    [agsCfTaskParams setIncidentsWithFeatures:[[NSArray alloc] initWithObjects:agsGraphicIncident, nil]];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    AGSGraphic *agsGraphicFacilities = [[AGSGraphic alloc] init];
    
    for (AGSGraphic *agsGraphic in self.agsFeatureLayer.graphics) {
        AGSPoint *agsPointFacility = (AGSPoint *)[agsGeomEngine projectGeometry:agsGraphic.geometry toSpatialReference:[AGSSpatialReference spatialReferenceWithWKID:102100]];
        
        agsGraphicFacilities.geometry = agsPointFacility;
        [array addObject:agsGraphicFacilities];
        
    }
    
    [agsCfTaskParams setFacilitiesWithFeatures:array];
    
    [self.agsCfTask solveClosestFacilityWithParameters:agsCfTaskParams];
    
}


- (void)closestFacilityTask:(AGSClosestFacilityTask *)closestFacilityTask operation:(NSOperation *)op didSolveClosestFacilityWithResult:(AGSClosestFacilityTaskResult *)closestFacilityTaskResult {
    
    // 最寄施設検索結果の取得ルートを表示
    NSLog(@"Count: %lu", (unsigned long)[closestFacilityTaskResult.closestFacilityResults count]);
    
    AGSClosestFacilityResult *agsCFResult = [closestFacilityTaskResult.closestFacilityResults objectAtIndex:0];
    
    // 最寄施設検へのルートを表示
    AGSSimpleLineSymbol *agsSimpleLineSym = [AGSSimpleLineSymbol simpleLineSymbol];
    agsSimpleLineSym.style = AGSSimpleLineSymbolStyleSolid;
    agsSimpleLineSym.color = [UIColor cyanColor];
    agsSimpleLineSym.width = 2.0;
    
    AGSGraphic *agsGraphic = agsCFResult.routeGraphic;
    agsGraphic.symbol = agsSimpleLineSym;
    
    [(AGSGraphicsLayer *)[self.agsMapView mapLayerForName:@"Graphics Layer"] removeAllGraphics];
    [(AGSGraphicsLayer *)[self.agsMapView mapLayerForName:@"Graphics Layer"] addGraphic:agsGraphic];
    
    [self.agsMapView zoomToEnvelope:agsGraphic.geometry.envelope animated:YES];
    
}


- (void)closestFacilityTask:(AGSClosestFacilityTask *)closestFacilityTask operation:(NSOperation *)op didFailSolveWithError:(NSError *)error {
    
    // 最寄り施設検索に失敗した旨をメッセージ表示
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"最寄り施設を検索できませんでした。" message:[NSString stringWithFormat:@"Error:%@", error] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}




@end
