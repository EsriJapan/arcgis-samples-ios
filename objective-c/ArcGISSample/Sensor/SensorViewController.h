//
//  SensorViewController.h
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <ArcGIS/ArcGIS.h>

@interface SensorViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) AGSMapView *agsMapView;
@property (nonatomic, strong) CLLocationManager *locationManager;


@end
