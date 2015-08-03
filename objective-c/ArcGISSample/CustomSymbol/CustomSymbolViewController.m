//
//  CustomSymbolViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "CustomSymbolViewController.h"


@implementation CustomSymbolViewController




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
    AGSGraphicsLayer *agsGraphicsLayer = [[AGSGraphicsLayer graphicsLayer] initWithFullEnvelope:self.agsMapView.maxEnvelope renderingMode:AGSGraphicsLayerRenderingModeDynamic];
    [self.agsMapView addMapLayer:agsGraphicsLayer withName:@"Graphics Layer"];
	
	AGSPoint *point = [AGSPoint pointWithX:15554789.5566484 y:4254781.24130285 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:102100]];
    [self.agsMapView zoomToScale:100000 withCenterPoint:point animated:YES];
    
    
    //マーカーシンボルを作成してグラフィックスレイヤーに追加
    AGSPictureMarkerSymbol *agsMarkerSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[self getImage]];
    AGSGraphic *pointGraphic = [AGSGraphic graphicWithGeometry:point symbol:agsMarkerSymbol attributes:nil];
	[agsGraphicsLayer addGraphic:pointGraphic];

    //テキストシンボルを作成してグラフィックスレイヤーに追加
	AGSTextSymbol *agsTextSym = [[AGSTextSymbol alloc] init];
	agsTextSym.text = @"東京ミッドタウン";
	agsTextSym.fontSize = 20.0f;
	agsTextSym.fontFamily = @"Hiragino Kaku Gothic ProN W6";
    agsTextSym.bold = true;
    agsTextSym.color = [UIColor blackColor];
    
    AGSGraphic *agsTextGraphic = [AGSGraphic graphicWithGeometry:point symbol:agsTextSym attributes:nil];
	[agsGraphicsLayer addGraphic:agsTextGraphic];
    
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    slider.minimumValue = -180.0f;
    slider.maximumValue = 180.0f;
    [slider addTarget:self action:@selector(sliderEvent:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];

    
}




- (void)sliderEvent:(UISlider *)slider {
    
    //レイヤー名を指定して、マップ上のレイヤーを取得
    AGSGraphicsLayer *graphicsLayer = (AGSGraphicsLayer *)[self.agsMapView mapLayerForName:@"Graphics Layer"];
    
    //シンボルをUISliderの値に応じて回転
    AGSGraphic *agsPointGraphic = [graphicsLayer.graphics objectAtIndex:0];
    AGSPictureMarkerSymbol *pointSymbol = (AGSPictureMarkerSymbol *)agsPointGraphic.symbol;
    pointSymbol.angle = -slider.value;
    
    AGSGraphic *agsTextGraphic = [graphicsLayer.graphics objectAtIndex:1];
    AGSTextSymbol *textSymbol = (AGSTextSymbol *)agsTextGraphic.symbol;
    textSymbol.angle = -slider.value;
    
}


- (UIImage *)getImage {
    
    //マーカーシンボルに表示する画像を作成する
    UIGraphicsBeginImageContext(CGSizeMake(48, 48));
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    CGContextSaveGState(context);

    CGContextSetShadow(context, CGSizeMake(2, 6), 1);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, 36, 36));
    CGContextRestoreGState(context);
    
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    size_t num_locations = 5;
    CGFloat locations[5] = { 0.00, 0.2528, 0.5955, 0.7865, 1 };
    CGFloat components[21] = {1.0, 1.0, 1,0, 0.9, 1.0, 0.992157, 0.917647, 0.9, 0.878431, 0.854902, 0.811765, 0.9, 0.956863, 0.956863, 0.956863, 0.9, 0.882353, 0.870588, 0.780392, 0.9};
    
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, num_locations);
    
    CGPoint myStartPoint, myEndPoint;
    CGFloat myStartRadius, myEndRadius;
    myStartPoint.x = myStartPoint.y = 12;
    myEndPoint.x = myEndPoint.y = 16;
    myStartRadius = 0;
    myEndRadius = 28;
    
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, 36, 36));
    CGContextClip(context);
    
    CGContextDrawRadialGradient(context, myGradient, myStartPoint, myStartRadius, myEndPoint, myEndRadius, kCGGradientDrawsBeforeStartLocation);
    
    CGColorSpaceRelease(myColorspace);
    
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return image;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
