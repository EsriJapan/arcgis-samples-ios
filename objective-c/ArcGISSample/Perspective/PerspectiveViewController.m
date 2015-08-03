//
//  PerspectiveViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "PerspectiveViewController.h"



@implementation PerspectiveViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //道路地図レイヤー追加用のマップを作成
    self.agsMapView1 = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    self.agsMapView1.tag = 1;
    self.agsMapView1.layerDelegate = self;
	[self.view addSubview:self.agsMapView1];

    //タイルマップサービスレイヤーの追加（道路地図）
    NSURL *url1 = [NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
    AGSTiledMapServiceLayer *tiledMapServiceLayer1 = [[AGSTiledMapServiceLayer alloc] initWithURL:url1];
    [self.agsMapView1 addMapLayer:tiledMapServiceLayer1 withName:@"Tiled Layer1"];    
    
    //衛星画像レイヤー追加用のマップを作成
    self.agsMapView2 = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    self.agsMapView2.tag = 2;
    self.agsMapView2.layerDelegate = self;
    [self.view addSubview:self.agsMapView2];
    
    //タイルマップサービスレイヤーの追加（衛星画像）
    NSURL *url2 = [NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer"];
    AGSTiledMapServiceLayer *tiledMapServiceLayer2 = [[AGSTiledMapServiceLayer alloc] initWithURL:url2];
    [self.agsMapView2 addMapLayer:tiledMapServiceLayer2 withName:@"Tiled Layer2"];

    
    UIBarButtonItem *persItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(buttonEvent:)];
    self.navigationItem.rightBarButtonItem = persItem;
    
    self.perspective = NO;
    
}


- (void)mapViewDidLoad:(AGSMapView *)mapView {
    
    //マップのズームとパンニングを監視して通知する
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter	addObserver:self selector:@selector(respondToEndPanning:) name:AGSMapViewDidEndPanningNotification object:mapView];
	[notificationCenter	addObserver:self selector:@selector(respondToEndZooming:) name:AGSMapViewDidEndZoomingNotification object:mapView];
    
}


- (void)respondToEndPanning:(NSNotification *)notification {
    
    //マップのパンニング完了時にレイヤーの表示範囲を設定
    if (self.agsMapView1.interacting == NO && self.agsMapView2.interacting == NO) {
        
        AGSMapView *mapView = notification.object;
        if (mapView.tag == 1) {
            [self.agsMapView2 zoomToEnvelope:self.agsMapView1.visibleAreaEnvelope animated:YES];
        } else if(mapView.tag == 2) {
            [self.agsMapView1 zoomToEnvelope:self.agsMapView2.visibleAreaEnvelope animated:YES];
        }
    }
 
}

- (void)respondToEndZooming:(NSNotification *)notification {
    
    //マップのズーム完了時にレイヤーの表示範囲を設定
    if (self.agsMapView1.interacting == NO && self.agsMapView2.interacting == NO) {
        
        AGSMapView *mapView = notification.object;
        if (mapView.tag == 1) {
            [self.agsMapView2 zoomToEnvelope:self.agsMapView1.visibleAreaEnvelope animated:YES];
        } else if(mapView.tag == 2) {
            [self.agsMapView1 zoomToEnvelope:self.agsMapView2.visibleAreaEnvelope animated:YES];
        }
    }
 
}



- (void)buttonEvent:(UIButton *)button {
    
    if (self.perspective) {
        [self reversePerspectiveAnimation];
        self.perspective = NO;
    } else {
        [self perspectiveAnimation];
        self.perspective = YES;
    }
}


- (void)perspectiveAnimation
{
    //マップのUIViewを透視投影
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    animation.repeatCount = 0;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    CATransform3D transformID = CATransform3DIdentity;
    transformID.m34 = 1.0 / -1000;
    animation.fromValue = [NSValue valueWithCATransform3D:transformID];
    
    CATransform3D scaleAnim1 = CATransform3DMakeScale(0.8, 0.8, 0.8);    
    CATransform3D rotateAnim1 = CATransform3DRotate(transformID, 45.0 * M_PI / 180.0, 1.0, -0.5, 0.5);
    CATransform3D transAnim1 = CATransform3DMakeTranslation(0.0, 100.0, 0.0);
    CATransform3D combineAnim1 = CATransform3DConcat(scaleAnim1, rotateAnim1);
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(combineAnim1, transAnim1)];
    
    self.agsMapView1.layer.transform = CATransform3DConcat(combineAnim1, transAnim1);
    CALayer *caLayer1 = self.agsMapView1.layer;
    caLayer1.shadowColor = [UIColor blackColor].CGColor;
    caLayer1.shadowRadius = 3;
    caLayer1.shadowOffset = CGSizeMake(10, 10);
    caLayer1.shadowOpacity = 0.7f;
    [caLayer1 addAnimation:animation forKey:@"transform1"];

    CATransform3D scaleAnim2 = CATransform3DMakeScale(0.8, 0.8, 0.8);
    CATransform3D rotateAnim2 = CATransform3DRotate(transformID, 45.0 * M_PI / 180.0, 1.0, -0.5, 0.5);
    CATransform3D transAnim2 = CATransform3DMakeTranslation(0.0, -150.0, 100.0);
    CATransform3D combineAnim2 = CATransform3DConcat(scaleAnim2, rotateAnim2);
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(combineAnim2, transAnim2)];
    
    self.agsMapView2.layer.transform = CATransform3DConcat(combineAnim2, transAnim2);
    CALayer *caLayer2 = self.agsMapView2.layer;
    caLayer2.shadowColor = [UIColor blackColor].CGColor;
    caLayer2.shadowRadius = 3;
    caLayer2.shadowOffset = CGSizeMake(10, 10);
    caLayer2.shadowOpacity = 0.7f;
    [caLayer2 addAnimation:animation forKey:@"transform2"];
    
}



- (void)reversePerspectiveAnimation
{
    
    //マップの表示状態を元に戻す
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    animation.repeatCount = 0;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    CATransform3D transformID = CATransform3DIdentity;
    transformID.m34 = 1.0 / -1000;
    animation.toValue = [NSValue valueWithCATransform3D:transformID];
    
    CATransform3D scaleAnim1 = CATransform3DMakeScale(0.8, 0.8, 0.8);
    CATransform3D rotateAnim1 = CATransform3DRotate(transformID, 45.0 * M_PI / 180.0, 1.0, -0.5, 0.5);
    CATransform3D transAnim1 = CATransform3DMakeTranslation(0.0, 100.0, 0.0);
    CATransform3D combineAnim1 = CATransform3DConcat(scaleAnim1, rotateAnim1);
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(combineAnim1, transAnim1)];
    
    self.agsMapView1.layer.transform = transformID;
    CALayer *caLayer1 = self.agsMapView1.layer;
    caLayer1.shadowOpacity = 0.0f;
    [caLayer1 addAnimation:animation forKey:@"transform1"];

    CATransform3D scaleAnim2 = CATransform3DMakeScale(0.8, 0.8, 0.8);
    CATransform3D rotateAnim2 = CATransform3DRotate(transformID, 45.0 * M_PI / 180.0, 1.0, -0.5, 0.5);
    CATransform3D transAnim2 = CATransform3DMakeTranslation(0.0, -150.0, 0.0);
    CATransform3D combineAnim2 = CATransform3DConcat(scaleAnim2, rotateAnim2);
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(combineAnim2, transAnim2)];
    
    self.agsMapView2.layer.transform = transformID;
    CALayer *caLayer2 = self.agsMapView2.layer;
    caLayer2.shadowOpacity = 0.0f;
    [caLayer2 addAnimation:animation forKey:@"transform2"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
