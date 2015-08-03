//
//  SketchViewController.h
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>


@interface SketchViewController : UIViewController


@property (nonatomic, strong) AGSGraphicsLayer *agsGraphicsLayer;
@property (nonatomic, strong) AGSSketchGraphicsLayer *agsSketchGraphicsLayer;



@end
