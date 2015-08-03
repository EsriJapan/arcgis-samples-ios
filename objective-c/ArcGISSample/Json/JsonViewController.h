//
//  JsonViewController.h
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>


@interface JsonViewController : UIViewController <AGSLayerCalloutDelegate>

@property (nonatomic, strong) AGSMapView *agsMapView;


@end
