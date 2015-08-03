//
//  NetworkViewController.h
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface NetworkViewController : UIViewController <AGSRouteTaskDelegate>


@property (nonatomic, strong) AGSMapView *agsMapView;
@property (nonatomic, strong) AGSRouteTask *agsRouteTask;
@property (nonatomic, strong) AGSRouteResult *agsRouteResult;

@property (nonatomic, retain) UILabel *directionLabel;
@property (nonatomic, retain) NSMutableArray *stopPoints;

@property (nonatomic, assign) NSInteger directionIndex;
@property (nonatomic, assign) NSInteger pointIndex;


@end
