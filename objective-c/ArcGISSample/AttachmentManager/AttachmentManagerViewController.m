//
//  AttachmentManagerViewController.m
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

#import "AttachmentManagerViewController.h"


@implementation AttachmentManagerViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.agsMapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:self.agsMapView];
    
    //タイルマップサービスレイヤーの追加
    NSURL *url = [NSURL URLWithString:@"https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
    AGSTiledMapServiceLayer *agsTiledMapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    [self.agsMapView addMapLayer:agsTiledMapServiceLayer withName:@"Tiled layer"];
    
    //写真を添付する編集用フィーチャレイヤーの追加
    //NSURL *featureLayerUrl = [NSURL URLWithString:@"http://sampleserver3.arcgisonline.com/ArcGIS/rest/services/SanFrancisco/311Incidents/FeatureServer/0"];
    NSURL *featureLayerUrl = [NSURL URLWithString:@"http://sampleserver6.arcgisonline.com/arcgis/rest/services/CommercialDamageAssessment/FeatureServer/0"];
    self.agsFeatureLayer = [AGSFeatureLayer featureServiceLayerWithURL:featureLayerUrl mode:AGSFeatureLayerModeOnDemand];
    [self.agsMapView addMapLayer:self.agsFeatureLayer withName:@"Feature Layer"];

    
    UIBarButtonItem *buttonAttachment = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAttachment)];
    NSArray *buttons = [NSArray arrayWithObjects:buttonAttachment, nil];
	
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
	[toolbar setItems:buttons];	
	[self.view addSubview:toolbar];
    
    //マップの中心にカーソルを表示
    [self drawCenterSign];
    
    
}

- (void)drawCenterSign {
    
    UIGraphicsBeginImageContext(CGSizeMake(20, 20));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 10, 0);
    CGContextAddLineToPoint(context, 10, 20);
    CGContextMoveToPoint(context, 0, 10);
    CGContextAddLineToPoint(context, 20, 10);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 10, 9);
    CGContextAddLineToPoint(context, 10, 11);
    CGContextMoveToPoint(context, 9, 10);
    CGContextAddLineToPoint(context, 11, 9);
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CALayer *caLayer = [CALayer layer];
    caLayer.frame = CGRectMake(self.agsMapView.frame.size.width / 2 - 10, self.agsMapView.frame.size.height / 2 - 10, 20, 20);
    caLayer.contents = (id)image.CGImage;
    [self.view.layer addSublayer:caLayer];
    
}


- (void)addAttachment {
    
    //添付する写真をフォトライブリから選択
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];

    //ジオメトリと属性を指定してフィーチャを新規に作成する
    AGSPoint *agsPoint = self.agsMapView.visibleAreaEnvelope.center;
    AGSGraphic *agsFeature = [[AGSGraphic alloc] init];
    agsFeature.geometry = agsPoint;
    //[agsFeature setAttribute:@"Tree Maintenance or Damage" forKey:@"req_type"];
    [agsFeature setAttribute:@"Minor" forKey:@"typdamage"];
    
    //フィーチャをフィーチャレイヤーに更新
    [self.agsFeatureLayer applyEditsWithFeaturesToAdd:[NSArray arrayWithObject:agsFeature] toUpdate:nil toDelete:nil];
    self.agsFeatureLayer.editingDelegate = self;
    
}


- (void)featureLayer:(AGSFeatureLayer *) featureLayer operation:(NSOperation *) op didFailFeatureEditsWithError:(NSError *)error{
    
    NSLog(@"Error:%@", error);
    
}


- (void)featureLayer:(AGSFeatureLayer *) featureLayer operation:(NSOperation *) op didFeatureEditsWithResults:(AGSFeatureLayerEditResults *) editResults
{
    
    //新規に作成したフィーチャに対してAGSAttachmentManagerを作成
    AGSEditResult *results = [editResults.addResults objectAtIndex:0];
    AGSGraphic *agsFeature = [self.agsFeatureLayer lookupFeatureWithObjectId:results.objectId];
    self.agsAttachmentMgr = [self.agsFeatureLayer attachmentManagerForFeature:agsFeature];
    self.agsAttachmentMgr.delegate = self;
    
    //フォトライブリから選択した写真に名前を指定してフィーチャに添付
    [self.agsAttachmentMgr addAttachmentAsJpgWithImage:self.image name:@"temp.jpg"];
    
    if([self.agsAttachmentMgr hasLocalEdits])
        [self.agsAttachmentMgr postLocalEditsToServer];
    
}



- (void)attachmentManager:(AGSAttachmentManager *)attachmentManager didPostLocalEditsToServer:(NSArray *)attachmentsPosted {
    
    BOOL success = YES;
    
    for (AGSAttachment* attachment in attachmentsPosted) {
        
        //写真の添付に失敗
        if(attachment.networkError != nil || attachment.editResultError != nil){
            
            success = NO;
            
            if(attachment.networkError!=nil) {
                
                NSString *reason = [attachment.networkError localizedDescription];
                NSLog(@"Error: %@", reason);

            } else if(attachment.editResultError !=nil) {
                
                NSString *reason = attachment.editResultError.errorDescription;
                NSLog(@"Error: %@", reason);
                
            }
        }
    }
    
    //写真の添付に成功
    if(success){
        
        NSLog(@"didPostLocalEditsToServer");
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
