//
//  PerspectiveViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS

class PerspectiveViewController: UIViewController, AGSMapViewLayerDelegate {
    
    
    var agsMapView1: AGSMapView!
    var agsMapView2: AGSMapView!
    var perspective: Bool! = false

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //道路地図レイヤー追加用のマップを作成
        self.agsMapView1 = AGSMapView(frame: self.view.bounds)
        self.agsMapView1.tag = 1
        self.agsMapView1.layerDelegate = self
        self.view.addSubview(self.agsMapView1)
        
        //タイルマップサービスレイヤーの追加（道路地図）
        let url1 = NSURL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr1 = AGSTiledMapServiceLayer(URL:url1)
        self.agsMapView1.addMapLayer(tiledLyr1, withName:"Tiled Layer1")
        
        //衛星画像レイヤー追加用のマップを作成
        self.agsMapView2 = AGSMapView(frame: self.view.bounds)
        self.agsMapView2.tag = 2
        self.agsMapView2.layerDelegate = self
        self.view.addSubview(self.agsMapView2)
        
        //タイルマップサービスレイヤーの追加（衛星画像）
        let url2 = NSURL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer")
        let tiledLyr2 = AGSTiledMapServiceLayer(URL:url2)
        self.agsMapView2.addMapLayer(tiledLyr2, withName:"Tiled Layer2")
        
        
        let persItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(PerspectiveViewController.buttonEvent))
        self.navigationItem.rightBarButtonItem = persItem
        
        self.perspective = false
        
    }
    
    
    func mapViewDidLoad(mapView: AGSMapView!) {
        
        //マップのズームとパンニングを監視して通知する
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(PerspectiveViewController.respondToEndPanning), name: "AGSMapViewDidEndPanningNotification", object: mapView)
        notificationCenter.addObserver(self, selector: #selector(PerspectiveViewController.respondToEndZooming), name: "AGSMapViewDidEndZoomingNotification", object: mapView)
        
    }
    
    
    func respondToEndPanning(notification: NSNotification?) {
        
        //マップのパンニング完了時にレイヤーの表示範囲を設定
        if self.agsMapView1.interacting == false && self.agsMapView2.interacting == false {
            
            let mapView: AnyObject? = notification!.object
            if mapView!.tag == 1 {
                self.agsMapView2.zoomToEnvelope(self.agsMapView1.visibleAreaEnvelope, animated: true)
            } else if mapView!.tag == 2 {
                self.agsMapView1.zoomToEnvelope(self.agsMapView2.visibleAreaEnvelope, animated: true)
            }
            
        }
        
    }
    
    func respondToEndZooming(notification: NSNotification?) {
        
        //マップのズーム完了時にレイヤーの表示範囲を設定
        if self.agsMapView1.interacting == false && self.agsMapView2.interacting == false {
            
            let mapView: AnyObject? = notification!.object
            if mapView!.tag == 1 {
                self.agsMapView2.zoomToEnvelope(self.agsMapView1.visibleAreaEnvelope, animated: true)
            } else if mapView!.tag == 2 {
                self.agsMapView1.zoomToEnvelope(self.agsMapView2.visibleAreaEnvelope, animated: true)
            }
            
        }
        
    }
    

    func buttonEvent(sender: UIBarButtonItem) {
        
        if self.perspective == true {
            self.reversePerspectiveAnimation()
            self.perspective = false
        } else {
            self.perspectiveAnimation()
            self.perspective = true
        }
        
    }
    
    
    func perspectiveAnimation() {

        //マップのUIViewを透視投影
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = 0.5
        animation.repeatCount = 0
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        
        var transformID = CATransform3DIdentity
        transformID.m34 = 1.0 / -1000
        animation.fromValue = NSValue(CATransform3D : transformID)

        let scaleAnim1 = CATransform3DMakeScale(0.8, 0.8, 0.8)
        let rotateAnim1 = CATransform3DRotate(transformID, 45.0 * CGFloat(M_PI / 180.0), 1.0, -0.5, 0.5)
        let transAnim1 = CATransform3DMakeTranslation(0.0, 100.0, 0.0)
        let combineAnim1 = CATransform3DConcat(scaleAnim1, rotateAnim1)
        animation.toValue = NSValue(CATransform3D: CATransform3DConcat(combineAnim1, transAnim1))
        
        self.agsMapView1.layer.transform = CATransform3DConcat(combineAnim1, transAnim1)
        let caLayer1 = self.agsMapView1.layer
        caLayer1.shadowColor = UIColor.blackColor().CGColor
        caLayer1.shadowRadius = 3;
        caLayer1.shadowOffset = CGSizeMake(10, 10)
        caLayer1.shadowOpacity = 0.7
        caLayer1 .addAnimation(animation, forKey: "transform1")
        
        let scaleAnim2 = CATransform3DMakeScale(0.8, 0.8, 0.8)
        let rotateAnim2 = CATransform3DRotate(transformID, 45.0 * CGFloat(M_PI / 180.0), 1.0, -0.5, 0.5)
        let transAnim2 = CATransform3DMakeTranslation(0.0, -150.0, 100.0)
        let combineAnim2 = CATransform3DConcat(scaleAnim2, rotateAnim2)
        animation.toValue = NSValue(CATransform3D: CATransform3DConcat(combineAnim2, transAnim2))

        self.agsMapView2.layer.transform = CATransform3DConcat(combineAnim2, transAnim2)
        let caLayer2 = self.agsMapView2.layer
        caLayer2.shadowColor = UIColor.blackColor().CGColor
        caLayer2.shadowRadius = 3
        caLayer2.shadowOffset = CGSizeMake(10, 10)
        caLayer2.shadowOpacity = 0.7
        caLayer2 .addAnimation(animation, forKey: "transform2")

    }
    
    
    func reversePerspectiveAnimation() {
        
        //マップの表示状態を元に戻す
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = 0.5
        animation.repeatCount = 0
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        
        var transformID = CATransform3DIdentity
        transformID.m34 = 1.0 / -1000
        animation.toValue = NSValue(CATransform3D : transformID)
        
        let scaleAnim1 = CATransform3DMakeScale(0.8, 0.8, 0.8)
        let rotateAnim1 = CATransform3DRotate(transformID, 45.0 * CGFloat(M_PI / 180.0), 1.0, -0.5, 0.5)
        let transAnim1 = CATransform3DMakeTranslation(0.0, 100.0, 0.0)
        let combineAnim1 = CATransform3DConcat(scaleAnim1, rotateAnim1)
        animation.fromValue = NSValue(CATransform3D: CATransform3DConcat(combineAnim1, transAnim1))
        
        self.agsMapView1.layer.transform = transformID
        let caLayer1 = self.agsMapView1.layer
        caLayer1.shadowOpacity = 0
        caLayer1 .addAnimation(animation, forKey: "transform1")
        
        let scaleAnim2 = CATransform3DMakeScale(0.8, 0.8, 0.8)
        let rotateAnim2 = CATransform3DRotate(transformID, 45.0 * CGFloat(M_PI / 180.0), 1.0, -0.5, 0.5)
        let transAnim2 = CATransform3DMakeTranslation(0.0, -150.0, 0.0)
        let combineAnim2 = CATransform3DConcat(scaleAnim2, rotateAnim2)
        animation.fromValue = NSValue(CATransform3D: CATransform3DConcat(combineAnim2, transAnim2))
        
        self.agsMapView2.layer.transform = transformID
        let caLayer2 = self.agsMapView2.layer
        caLayer2.shadowOpacity = 0
        caLayer2 .addAnimation(animation, forKey: "transform2")

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}