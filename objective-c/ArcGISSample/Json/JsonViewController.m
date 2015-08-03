//
//  JsonViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "JsonViewController.h"

@implementation JsonViewController

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
    

    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [path objectAtIndex:0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"offlineFeature"];
    
    
    //新規フィーチャーを作成
    AGSPoint *point = [AGSPoint pointWithX:15554789.5566484 y:4254781.24130285 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:102100]];
    AGSSimpleMarkerSymbol *markerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor blueColor]];
    AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:point symbol:markerSymbol attributes:[NSDictionary dictionaryWithObject:@"東京ミッドタウン" forKey:@"att"]];
    [self.agsMapView zoomToScale:100000 withCenterPoint:point animated:YES];
    
    //フィーチャーをJSONにエンコード
    AGSFeatureSet *agsFeatureSet = [AGSFeatureSet featureSetWithFeatures:[NSArray arrayWithObjects:graphic, nil]];
    NSDictionary *json = [agsFeatureSet encodeToJSON];
    NSString *jsonString = [json ags_JSONRepresentation];

    //JSONの文字列をファイルに保存
    BOOL bSuccess = [jsonString writeToFile:filePath atomically:YES encoding:NSUnicodeStringEncoding error:nil];
    if (bSuccess) {
        NSLog(@"保存場所:%@, JSON:%@", filePath, jsonString);
    }
    
    //JSONの文字列からフィーチャを新規作成
    NSString *fSetString = [NSString stringWithContentsOfFile:filePath encoding:NSUnicodeStringEncoding error:nil];
    NSDictionary *fSetDictionary = (NSDictionary *)[fSetString ags_JSONValue];
    AGSFeatureSet *offlineFset = [[AGSFeatureSet alloc] initWithJSON:fSetDictionary];
    
    //フィーチャをグラフィックスレイヤーに追加
    [graphicsLayer addGraphics:offlineFset.features];
    
    graphicsLayer.calloutDelegate = self;
    
}

-(BOOL)callout:(AGSCallout*)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable>*)layer mapPoint:(AGSPoint*)mapPoint{

    //フィーチャをタップすると属性を表示
    self.agsMapView.callout.title = @"属性";
    self.agsMapView.callout.detail =(NSString*)[feature attributeForKey:@"att"];
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
