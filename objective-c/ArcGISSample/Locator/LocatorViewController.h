//
//  LocatorViewController.h
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>


@interface LocatorViewController : UIViewController <AGSMapViewTouchDelegate, AGSLocatorDelegate>

@property (nonatomic, strong) AGSMapView *agsMapView;
@property (nonatomic, strong) AGSLocator *agsLocator;
@property (nonatomic, strong) AGSPoint *agsPoint;

@end
