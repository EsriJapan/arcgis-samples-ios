//
//  PerspectiveViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS

class PerspectiveViewController: UIViewController, AGSMapViewLayerDelegate, CAAnimationDelegate {
    
    
    var agsMapView1: AGSMapView!
    var agsMapView2: AGSMapView!
    var perspective: Bool! = false

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //道路地図レイヤー追加用のマップを作成
        agsMapView1 = AGSMapView(frame: view.bounds)
        agsMapView1.tag = 1
        agsMapView1.layerDelegate = self
        view.addSubview(agsMapView1)
        
        //タイルマップサービスレイヤーの追加（道路地図）
        let url1 = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr1 = AGSTiledMapServiceLayer(url:url1)
        agsMapView1.addMapLayer(tiledLyr1, withName:"Tiled Layer1")
        
        //衛星画像レイヤー追加用のマップを作成
        agsMapView2 = AGSMapView(frame: view.bounds)
        agsMapView2.tag = 2
        agsMapView2.layerDelegate = self
        view.addSubview(agsMapView2)
        
        //タイルマップサービスレイヤーの追加（衛星画像）
        let url2 = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer")
        let tiledLyr2 = AGSTiledMapServiceLayer(url:url2)
        agsMapView2.addMapLayer(tiledLyr2, withName:"Tiled Layer2")
        
        
        let persItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(PerspectiveViewController.buttonEvent))
        navigationItem.rightBarButtonItem = persItem
        
        perspective = false
        
    }
    
    
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        
        //マップのズームとパンニングを監視して通知する
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(PerspectiveViewController.respondToEndPanning), name: NSNotification.Name(rawValue: "AGSMapViewDidEndPanningNotification"), object: mapView)
        notificationCenter.addObserver(self, selector: #selector(PerspectiveViewController.respondToEndZooming), name: NSNotification.Name(rawValue: "AGSMapViewDidEndZoomingNotification"), object: mapView)
        
    }
    
    
    func respondToEndPanning(_ notification: Notification?) {
        
        //マップのパンニング完了時にレイヤーの表示範囲を設定
        if agsMapView1.interacting == false && agsMapView2.interacting == false {
            
            let mapView = notification!.object as AnyObject?
            if mapView!.tag == 1 {
                agsMapView2.zoom(to: agsMapView1.visibleAreaEnvelope, animated: true)
            } else if mapView!.tag == 2 {
                agsMapView1.zoom(to: agsMapView2.visibleAreaEnvelope, animated: true)
            }
            
        }
        
    }
    
    func respondToEndZooming(_ notification: Notification?) {
        
        //マップのズーム完了時にレイヤーの表示範囲を設定
        if agsMapView1.interacting == false && agsMapView2.interacting == false {
            
            let mapView = notification!.object as AnyObject?
            if mapView!.tag == 1 {
                agsMapView2.zoom(to: agsMapView1.visibleAreaEnvelope, animated: true)
            } else if mapView!.tag == 2 {
                agsMapView1.zoom(to: agsMapView2.visibleAreaEnvelope, animated: true)
            }
            
        }
        
    }
    

    func buttonEvent(_ sender: UIBarButtonItem) {
        
        if perspective == true {
            reversePerspectiveAnimation()
            perspective = false
        } else {
            perspectiveAnimation()
            perspective = true
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
        animation.fromValue = NSValue(caTransform3D : transformID)

        let scaleAnim1 = CATransform3DMakeScale(0.8, 0.8, 0.8)
        let rotateAnim1 = CATransform3DRotate(transformID, 45.0 * CGFloat(M_PI / 180.0), 1.0, -0.5, 0.5)
        let transAnim1 = CATransform3DMakeTranslation(0.0, 100.0, 0.0)
        let combineAnim1 = CATransform3DConcat(scaleAnim1, rotateAnim1)
        animation.toValue = NSValue(caTransform3D: CATransform3DConcat(combineAnim1, transAnim1))
        
        agsMapView1.layer.transform = CATransform3DConcat(combineAnim1, transAnim1)
        let caLayer1 = agsMapView1.layer
        caLayer1.shadowColor = UIColor.black.cgColor
        caLayer1.shadowRadius = 3;
        caLayer1.shadowOffset = CGSize(width: 10, height: 10)
        caLayer1.shadowOpacity = 0.7
        caLayer1 .add(animation, forKey: "transform1")
        
        let scaleAnim2 = CATransform3DMakeScale(0.8, 0.8, 0.8)
        let rotateAnim2 = CATransform3DRotate(transformID, 45.0 * CGFloat(M_PI / 180.0), 1.0, -0.5, 0.5)
        let transAnim2 = CATransform3DMakeTranslation(0.0, -150.0, 100.0)
        let combineAnim2 = CATransform3DConcat(scaleAnim2, rotateAnim2)
        animation.toValue = NSValue(caTransform3D: CATransform3DConcat(combineAnim2, transAnim2))

        agsMapView2.layer.transform = CATransform3DConcat(combineAnim2, transAnim2)
        let caLayer2 = agsMapView2.layer
        caLayer2.shadowColor = UIColor.black.cgColor
        caLayer2.shadowRadius = 3
        caLayer2.shadowOffset = CGSize(width: 10, height: 10)
        caLayer2.shadowOpacity = 0.7
        caLayer2 .add(animation, forKey: "transform2")

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
        animation.toValue = NSValue(caTransform3D : transformID)
        
        let scaleAnim1 = CATransform3DMakeScale(0.8, 0.8, 0.8)
        let rotateAnim1 = CATransform3DRotate(transformID, 45.0 * CGFloat(M_PI / 180.0), 1.0, -0.5, 0.5)
        let transAnim1 = CATransform3DMakeTranslation(0.0, 100.0, 0.0)
        let combineAnim1 = CATransform3DConcat(scaleAnim1, rotateAnim1)
        animation.fromValue = NSValue(caTransform3D: CATransform3DConcat(combineAnim1, transAnim1))
        
        agsMapView1.layer.transform = transformID
        let caLayer1 = agsMapView1.layer
        caLayer1.shadowOpacity = 0
        caLayer1 .add(animation, forKey: "transform1")
        
        let scaleAnim2 = CATransform3DMakeScale(0.8, 0.8, 0.8)
        let rotateAnim2 = CATransform3DRotate(transformID, 45.0 * CGFloat(M_PI / 180.0), 1.0, -0.5, 0.5)
        let transAnim2 = CATransform3DMakeTranslation(0.0, -150.0, 0.0)
        let combineAnim2 = CATransform3DConcat(scaleAnim2, rotateAnim2)
        animation.fromValue = NSValue(caTransform3D: CATransform3DConcat(combineAnim2, transAnim2))
        
        agsMapView2.layer.transform = transformID
        let caLayer2 = agsMapView2.layer
        caLayer2.shadowOpacity = 0
        caLayer2 .add(animation, forKey: "transform2")

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
