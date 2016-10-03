//
//  SearchViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "SearchViewController.h"


@implementation SearchViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:self.agsMapView];
    
    //タイルマップサービスレイヤーの追加
    NSURL *url = [NSURL URLWithString:@"https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
    AGSTiledMapServiceLayer *tiledMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    [self.agsMapView addMapLayer:tiledMapServiceLayer withName:@"Tiled Layer"];
    
    //フィーチャ検索用のフィーチャレイヤーの表示
    NSURL *flayerUrl = [NSURL URLWithString:@"https://services3.arcgis.com/iH4Iz7CEdh5xTJYb/arcgis/rest/services/Nagareyama_shi_Shisetsu_All/FeatureServer/0"];
    AGSFeatureLayer *agsFeatureLayer = [AGSFeatureLayer featureServiceLayerWithURL:flayerUrl mode:AGSFeatureLayerModeOnDemand];
    agsFeatureLayer.outFields = [NSArray arrayWithObjects:@"*", nil];
    [self.agsMapView addMapLayer:agsFeatureLayer withName:@"Feature Layer"];
    
    //検索結果を表示するグラフィックスレイヤーを表示
    self.agsGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.agsMapView addMapLayer:self.agsGraphicsLayer withName:@"Graphics Layer"];
    
    AGSEnvelope *envelope = [AGSEnvelope envelopeWithXmin:139.891126 ymin:35.831845 xmax:139.9517425  ymax:35.9132698000001  spatialReference:[AGSSpatialReference spatialReferenceWithWKID:104111]];
    [self.agsMapView zoomToEnvelope:envelope animated:YES];

    //検索するレイヤーのURLを指定してフィーチャ検索用タスク（AGSQueryTask）を作成
    self.agsQueryTask = [[AGSQueryTask alloc] initWithURL:flayerUrl];
    self.agsQueryTask.delegate = self;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, 50)];
    searchBar.delegate = self;
    searchBar.text = @"子育て施設";
    [self.view addSubview:searchBar];
    
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    //フィーチャ検索用のパラメータを設定
    AGSQuery *agsQuery = [AGSQuery query];
    agsQuery.outFields = [NSArray arrayWithObjects:@"*", nil];
    agsQuery.returnGeometry = true;
    agsQuery.outSpatialReference = self.agsMapView.spatialReference;
    agsQuery.whereClause = [NSString stringWithFormat:@"%@ = '%@'", @"大分類", searchBar.text];
    
    //検索結果をソートするフィールドの指定
    NSMutableArray *order =[[NSMutableArray alloc] init];
    [order addObject:@"所在地"];
    agsQuery.orderByFields = order;

    //フィーチャ検索を実行
    [self.agsQueryTask executeWithQuery:agsQuery];

    [self.view endEditing:YES];

}

- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet
{
    
    [self.agsGraphicsLayer removeAllGraphics];
    
    AGSSymbol *mySymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:([UIColor whiteColor])];
    
    for (int i=0; i< [featureSet.features count]; i++) {
        
        //検索結果のフィーチャにシンボルを設定してグラフィックスレイヤーに追加
        AGSGraphic *graphic = [featureSet.features objectAtIndex:i];
        graphic.symbol = mySymbol;
        [self.agsGraphicsLayer addGraphic:graphic];
        [self.agsGraphicsLayer setSelected:YES forGraphic:graphic];
        NSLog(@"graphic: %@", [graphic attributeAsStringForKey:@"所在地"]);
    
    }

}


- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didFailWithError:(NSError *)error {
    
    NSLog(@"%@", error.localizedDescription);
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
