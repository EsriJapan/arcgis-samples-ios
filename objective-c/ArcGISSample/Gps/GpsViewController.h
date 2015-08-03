//
//  GpsViewController.h
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>


@interface GpsViewController : UIViewController <AGSMapViewLayerDelegate>

@property (nonatomic, strong) AGSMapView *agsMapView;

@property (nonatomic, retain) UIBarButtonItem *modeText;
@property (nonatomic, retain) UIBarButtonItem *dataText;

@property (nonatomic, assign) BOOL useGPX;


@end
