//
//  CoordinateConversionViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "CoordinateConversionViewController.h"


@implementation CoordinateConversionViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

    
    AGSMapView *agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:agsMapView];
    
    //タイルマップサービスレイヤーの追加
    NSURL *url = [NSURL URLWithString:@"https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
    AGSTiledMapServiceLayer *tiledMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    [agsMapView addMapLayer:tiledMapServiceLayer withName:@"Tiled Layer"];
    
    agsMapView.touchDelegate = self;
    

}


- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features{
    
    //マップ上でタップした場所からポイントを作成
    AGSPoint *myPoint = mappoint;
    
    NSString *decimalDegrees = [myPoint decimalDegreesStringWithNumDigits:10];
    NSString *decimalMinutes = [myPoint degreesDecimalMinutesStringWithNumDigits:10];
    NSString *decimalMinutesSeconds = [myPoint degreesMinutesSecondsStringWithNumDigits:10];
    NSString *GARS = [myPoint GARSString];
    NSString *GEOREF = [myPoint GEOREFStringWithNumDigits:10 rounding:YES];
    NSString *MGRS = [myPoint MGRSStringWithNumDigits:10 rounding:YES addSpaces:YES];
    NSString *USNG = [myPoint USNGStringWithNumDigits:10 rounding:YES addSpaces:YES];
    NSString *UTM = [myPoint UTMStringWithConversionMode:AGSUTMConversionModeNorthSouthIndicators addSpaces:YES];

    NSString *str =[NSString stringWithFormat:@"decimalDegrees:%@\ndecimalMinutes:%@\ndecimalMinutesSeconds:%@\nGARS:%@\nGEOREF:%@\nMGRS:%@\nUSNG:%@\nUTM:%@", decimalDegrees, decimalMinutes, decimalMinutesSeconds, GARS, GEOREF, MGRS, USNG, UTM];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"座標" message:str preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
