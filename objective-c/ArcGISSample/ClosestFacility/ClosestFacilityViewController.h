//
//  ClosestFacilityViewController.h
//  ArcGISDemo
//
//  Created by ej2047 on 11/07/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface ClosestFacilityViewController : UIViewController <AGSClosestFacilityTaskDelegate>

@property (nonatomic, retain) AGSMapView *agsMapView;
@property (nonatomic, retain) AGSFeatureLayer *agsFeatureLayer;
@property (nonatomic, retain) AGSClosestFacilityTask *agsCfTask;


@end
