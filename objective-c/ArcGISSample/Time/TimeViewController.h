//
//  TimeViewController.h
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <ArcGIS/ArcGIS.h>

@interface TimeViewController : UIViewController


@property (nonatomic, strong) AGSMapView *agsMapView;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;




@end
