//
//  SketchViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "SketchViewController.h"


@implementation SketchViewController


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    AGSMapView *agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:agsMapView];
    
    //タイルマップサービスレイヤーの追加
    NSURL *url = [NSURL URLWithString:@"https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
    AGSTiledMapServiceLayer *agsTiledMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    [agsMapView addMapLayer:agsTiledMapServiceLayer withName:@"Tiled Layer"];
    
    //スケッチしたグラフィック表示用のグラフィックスレイヤーの追加
    self.agsGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [agsMapView addMapLayer:self.agsGraphicsLayer withName:@"Graphics Layer"];
    
    //スケッチレイヤーの追加
    self.agsSketchGraphicsLayer = [[AGSSketchGraphicsLayer alloc] initWithGeometry:nil];
    self.agsSketchGraphicsLayer.midVertexSymbol = nil;
    [agsMapView addMapLayer:self.agsSketchGraphicsLayer withName:@"Sketch Layer"];
    
    //作成するジオメトリタイプの指定
    AGSMutablePolygon *agsSketchGeom = [[AGSMutablePolygon alloc] init];
    self.agsSketchGraphicsLayer.geometry = agsSketchGeom;
    
    agsMapView.touchDelegate = self.agsSketchGraphicsLayer;
    
    
    UIBarButtonItem *buttonUndo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(undoSketch)];
    UIBarButtonItem *buttonRedo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(redoSketch)];
    UIBarButtonItem *buttonRemove = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeVertex)];
    UIBarButtonItem *buttonSubmit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(submitFeature)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *buttons = [NSArray arrayWithObjects:buttonUndo, flexibleItem, buttonRedo, flexibleItem, buttonRemove, flexibleItem, buttonSubmit, nil];

	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
	[toolbar setItems:buttons];	
	[self.view addSubview:toolbar];
    

}


- (void)undoSketch {
    
    //編集を元に戻す
    if ([self.agsSketchGraphicsLayer.undoManager canUndo]) {
        [self.agsSketchGraphicsLayer.undoManager undo];
    }
    
}

- (void)redoSketch {
    
    //編集をやり直す
    if ([self.agsSketchGraphicsLayer.undoManager canRedo]) {
        [self.agsSketchGraphicsLayer.undoManager redo];
    }
    
}

- (void)removeVertex {
    
    //選択されている頂点を削除する
    [self.agsSketchGraphicsLayer removeSelectedVertex];
    
}

- (void)submitFeature {
    
    //作成したジオメトリからシンボルを指定してグラフィックを作成し、グラフィックスレイヤーに追加
    AGSSimpleFillSymbol *fillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
    fillSymbol.color = [[UIColor purpleColor] colorWithAlphaComponent:0.25];
    fillSymbol.outline.color = [UIColor darkGrayColor];
    
    AGSGraphic *agsGraphic = [[AGSGraphic alloc] initWithGeometry:self.agsSketchGraphicsLayer.geometry symbol:fillSymbol attributes:nil];
    [self.agsGraphicsLayer addGraphic:agsGraphic];
    
    [self.agsSketchGraphicsLayer clear];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
