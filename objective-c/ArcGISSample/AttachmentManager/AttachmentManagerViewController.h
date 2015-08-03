//
//  AttachmentManagerViewController.h
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>


@interface AttachmentManagerViewController : UIViewController <AGSAttachmentManagerDelegate, AGSFeatureLayerEditingDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>


@property (nonatomic, strong) AGSMapView *agsMapView;
@property (nonatomic, strong) AGSAttachmentManager *agsAttachmentMgr;
@property (nonatomic, strong) AGSFeatureLayer *agsFeatureLayer;

@property (nonatomic, retain) UIImage *image;



@end
