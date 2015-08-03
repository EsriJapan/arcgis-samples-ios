//
//  GpsViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "GpsViewController.h"


@implementation GpsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:self.agsMapView];
    
    //タイルマップサービスレイヤーの追加
	NSURL *url = [NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
	AGSTiledMapServiceLayer *tiledMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    [self.agsMapView addMapLayer:tiledMapServiceLayer withName:@"Tiled Layer"];
    self.agsMapView.layerDelegate = self;
    
    
    self.modeText = [[UIBarButtonItem alloc] initWithTitle:@"Off" style:UIBarButtonItemStylePlain target:self action:@selector(changeMode)];
    self.dataText = [[UIBarButtonItem alloc] initWithTitle:@"GPS" style:UIBarButtonItemStylePlain target:self action:@selector(changeData)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *buttons = [NSArray arrayWithObjects:self.modeText, flexibleItem, self.dataText, nil];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    [toolbar setItems:buttons];
    [self.view addSubview:toolbar];

}

-(void) mapViewDidLoad:(AGSMapView*)mapView {
    
    //マップが読み込まれたら位置情報の取得を開始
    [self.agsMapView.locationDisplay startDataSource];
    
}


-(void) changeMode {
    
    
    if (self.agsMapView.locationDisplay.autoPanMode == AGSLocationDisplayAutoPanModeOff){
        
        //位置情報の表示モードをAutoPanModeDefaultに変更
        self.agsMapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
        self.modeText.title = @"Default";
        
    } else if(self.agsMapView.locationDisplay.autoPanMode == AGSLocationDisplayAutoPanModeDefault){
        
        //位置情報の表示モードをAutoPanModeNavigationに変更
        self.agsMapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeNavigation;
        self.modeText.title = @"Navigation";
        
    } else if(self.agsMapView.locationDisplay.autoPanMode == AGSLocationDisplayAutoPanModeNavigation){
        
        //位置情報の表示モードをAutoPanModeCompassNavigationに変更
        self.agsMapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeCompassNavigation;
        self.modeText.title = @"CompassNavigation";
        
    } else if(self.agsMapView.locationDisplay.autoPanMode == AGSLocationDisplayAutoPanModeCompassNavigation){
        
        //位置情報の表示モードをAutoPanModeOffに変更
        self.agsMapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeOff;
        self.modeText.title = @"Off";
        
    }
}

- (void) changeData {
    
    
    if (self.useGPX) {
        
        self.useGPX = NO;
        self.dataText.title = @"GPS";
        //端末の位置情報サービスをもとにデバイスの位置情報をシミュレート
        AGSCLLocationManagerLocationDisplayDataSource *clLDS = [[AGSCLLocationManagerLocationDisplayDataSource alloc] init];
        self.agsMapView.locationDisplay.dataSource = clLDS;
        [self.agsMapView.locationDisplay startDataSource];
        
    } else {
        
        self.useGPX = YES;
        self.dataText.title = @"GPX";
        //gpxファイルのGPSログをもとにデバイスの位置情報をシミュレート
        NSString *gpxPath = [[NSBundle mainBundle] pathForResource:@"tokyo_yokohama" ofType:@"gpx"];
        AGSGPXLocationDisplayDataSource *gpxLDS = [[AGSGPXLocationDisplayDataSource alloc] initWithPath:gpxPath];
        self.agsMapView.locationDisplay.dataSource = gpxLDS;
        [self.agsMapView.locationDisplay startDataSource];
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
