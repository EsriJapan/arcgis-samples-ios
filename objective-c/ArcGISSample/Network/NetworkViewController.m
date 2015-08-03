//
//  NetworkViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "NetworkViewController.h"


@implementation NetworkViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
	self.agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:self.agsMapView];
    
    //タイルマップサービスレイヤーの追加
    NSURL *url = [NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
    AGSTiledMapServiceLayer *tiledMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    [self.agsMapView addMapLayer:tiledMapServiceLayer withName:@"Tiled Layer"];
    
    //初期表示範囲の設定
    AGSSpatialReference *agsSpRef = [AGSSpatialReference spatialReferenceWithWKID:102100];
    AGSPoint *point = [AGSPoint pointWithX:15554789.5566484 y:4254781.24130285 spatialReference:agsSpRef];
    [self.agsMapView zoomToScale:50000 withCenterPoint:point animated:YES];
    
    
    //認証の設定:検証用（ArcGIS Onlineのユーザー名とパスワードを指定）
    AGSCredential *credntial = [[AGSCredential alloc] initWithUser:@"<ユーザー名>" password:@"<パスワード>" authenticationType:AGSAuthenticationTypeToken];

    //ルート検索用のサービスURLの指定
    NSURL *networkUrl = [NSURL URLWithString:@"http://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World"];
    self.agsRouteTask = [[AGSRouteTask alloc] initWithURL:networkUrl credential:credntial];
    self.agsRouteTask.delegate = self;

    //検索結果のルートを表示するためのグラフィックスレイヤーを追加
    AGSGraphicsLayer *agsGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
	[self.agsMapView addMapLayer:agsGraphicsLayer withName:@"Graphics Layer"];
    
    //通過ポイントを表示するためのグラフィックスレイヤーを追加
    AGSGraphicsLayer *agsStopsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.agsMapView addMapLayer:agsStopsLayer withName:@"Stops Layer"];
    
    //通過ポイント格納用
    self.stopPoints = [[NSMutableArray alloc] init];

    self.directionLabel =[[UILabel alloc] init];
    [self.directionLabel setFrame:CGRectMake(0, 100, self.view.frame.size.width, 30)];
    self.directionLabel.backgroundColor = [UIColor darkGrayColor];
    self.directionLabel.alpha = 0.8;
    self.directionLabel.textColor = [UIColor whiteColor];
    self.directionLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:self.directionLabel];
    
    [[self.directionLabel layer] setCornerRadius:10.0];
    [self.directionLabel setClipsToBounds:YES];
    [[self.directionLabel layer] setBorderColor:[UIColor darkGrayColor].CGColor];
    [[self.directionLabel layer] setBorderWidth:3.0];
    
    
    UIBarButtonItem *buttonAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addStop)];
    UIBarButtonItem *buttonSolve = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(networkSolve)];
    UIBarButtonItem *buttonClear = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearStops)];
    UIBarButtonItem *buttonNext = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(moveToNextPoint)];
    NSArray *buttons = [NSArray arrayWithObjects:buttonAdd, buttonClear, buttonSolve, buttonNext, nil];

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
	caLayer.frame = CGRectMake(self.agsMapView.frame.size.width / 2 - 10, self.agsMapView.frame.size.height / 2 - 10, 20, 20);
	caLayer.contents = (id)image.CGImage;
	[self.view.layer addSublayer:caLayer];
    
}


- (void)addStop {
    
    //通過ポイントをグラフィックスレイヤーに追加
    AGSPoint *agsPoint = self.agsMapView.visibleAreaEnvelope.center;
    AGSSymbol *agsSym = [self stopSymbol];
    AGSGraphic *agsGraphic = [AGSGraphic graphicWithGeometry:agsPoint symbol:agsSym attributes:nil];
    [(AGSGraphicsLayer *)[self.agsMapView mapLayerForName:@"Stops Layer"] addGraphic:agsGraphic];
    
    //通過ポイントを配列に格納
    AGSStopGraphic *agsStopGraphic = [AGSStopGraphic graphicWithGeometry:agsPoint symbol:agsSym attributes:nil];
    [self.stopPoints addObject:agsStopGraphic];
    
}


- (void)clearStops {
    
    //グラフィックスレイヤーに追加されたグラフィックを削除
    [(AGSGraphicsLayer *)[self.agsMapView mapLayerForName:@"Graphics Layer"] removeAllGraphics];
    [(AGSGraphicsLayer *)[self.agsMapView mapLayerForName:@"Stops Layer"] removeAllGraphics];
    
    self.directionLabel.text = @"";
    [self.stopPoints removeAllObjects];
    self.agsRouteResult = nil;

}


- (void)networkSolve {
    
    self.pointIndex = 0;
    self.directionIndex = 0;
    
    //通過ポイントが2点以上ある場合
    if ([self.stopPoints count] > 1) {
        
        //ルート検索用のパラメータを設定
        AGSRouteTaskParameters *agsRouteTaskParams = [AGSRouteTaskParameters routeTaskParameters];
        agsRouteTaskParams.directionsLanguage = @"ja-JP";
        agsRouteTaskParams.returnRouteGraphics = YES;
        agsRouteTaskParams.returnDirections = YES;
        agsRouteTaskParams.outSpatialReference = [AGSSpatialReference spatialReferenceWithWKID:102100];
        [agsRouteTaskParams setStopsWithFeatures:self.stopPoints];
        
        //ルート検索を実行
        [self.agsRouteTask solveWithParameters:agsRouteTaskParams];
        
    } else {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"確認" message:@"通過点を2ポイント以上追加してください。" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
}



- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailSolveWithError:(NSError *)error
{
    //ルート検索の処理に失敗した場合にエラー内容を表示
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ルートを検索できませんでした。" message:[NSString stringWithFormat:@"Error:%@", error] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}



- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didSolveWithResult:(AGSRouteTaskResult *)routeTaskResult {
    
    //ルート検索結果からルートデータを取得
    self.agsRouteResult = [routeTaskResult.routeResults lastObject];
    
    //検索結果のルートデータをグラフィックスレイヤに表示
    AGSGraphic *agsGraphic = self.agsRouteResult.routeGraphic;
    agsGraphic.symbol = [self routeSymbol];
    [(AGSGraphicsLayer *)[self.agsMapView mapLayerForName:@"Graphics Layer"] addGraphic:agsGraphic];
    
    //検索結果のルートデータにズーム
    AGSMutableEnvelope *agsEnvelope = [self.agsRouteResult.routeGraphic.geometry.envelope mutableCopy];
    [agsEnvelope expandByFactor:2.0];
    [self.agsMapView zoomToEnvelope:agsEnvelope animated:YES];
    
}


- (AGSCompositeSymbol *)routeSymbol {
    
    //検索結果のルートシンボルの作成
	AGSCompositeSymbol *rs = [AGSCompositeSymbol compositeSymbol];
	
	AGSSimpleLineSymbol *sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
	sls1.color = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:0.9];
	sls1.style = AGSSimpleLineSymbolStyleSolid;
	sls1.width = 8;
	[rs addSymbol:sls1];
	
	AGSSimpleLineSymbol *sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
	sls2.color = [UIColor colorWithRed:0.5 green:0.2 blue:0.8 alpha:0.4];
	sls2.style = AGSSimpleLineSymbolStyleSolid;
	sls2.width = 4;
	[rs addSymbol:sls2];
	
	return rs;
}

- (AGSCompositeSymbol *)stopSymbol {
    
    //通過ポイントシンボルの作成
    AGSCompositeSymbol *ss = [AGSCompositeSymbol compositeSymbol];
    
    AGSSimpleMarkerSymbol *sms1 = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    sms1.color = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:0.9];
    sms1.style = AGSSimpleMarkerSymbolStyleCircle;
    sms1.size = CGSizeMake(18,18);
    [ss addSymbol:sms1];
    
    AGSSimpleMarkerSymbol *sms2 = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    sms2.color = [UIColor magentaColor];
    sms2.style = AGSSimpleMarkerSymbolStyleCircle;
    sms2.size = CGSizeMake(14, 14);
    [ss addSymbol:sms2];
    
    return ss;
}

- (void)moveToNextPoint {
    
    if (self.agsRouteResult == nil) {
        return;
    }
    
    //検索結果のルートデータの道順を表示する
    AGSDirectionSet *agsDirections = self.agsRouteResult.directions;
    AGSDirectionGraphic *agsDirectionGraphic = [agsDirections.graphics objectAtIndex:self.directionIndex];
    
    self.directionLabel.text = [NSString stringWithFormat:@"  %@", agsDirectionGraphic.text];
    
    AGSPolyline *agsDirectionPoly = (AGSPolyline *)agsDirectionGraphic.geometry;
    AGSPoint *agsPoint = [agsDirectionPoly pointOnPath:0 atIndex:self.pointIndex];
    [self.agsMapView centerAtPoint:agsPoint animated:YES];
    
    
    if (self.pointIndex == [agsDirectionPoly numPointsInPath:0] - 1) {
        self.pointIndex = 0;
        if (self.directionIndex == [agsDirections.graphics count] - 1) {
            self.directionIndex = 0;
        } else {
            self.directionIndex++;
        }
    } else {
        self.pointIndex++;
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
