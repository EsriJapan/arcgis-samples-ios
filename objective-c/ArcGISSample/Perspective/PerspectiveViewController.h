//
//  PerspectiveViewController.h
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>


@interface PerspectiveViewController : UIViewController <AGSMapViewLayerDelegate>

@property (nonatomic, strong) AGSMapView *agsMapView1;
@property (nonatomic, strong) AGSMapView *agsMapView2;

@property (nonatomic, assign) BOOL perspective;


@end
