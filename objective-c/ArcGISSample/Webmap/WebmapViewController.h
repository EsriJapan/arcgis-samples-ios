//
//  WebmapViewController.h
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>


@interface WebmapViewController : UIViewController <AGSWebMapDelegate>

@property (nonatomic, strong) AGSWebMap *webmap;


@end
