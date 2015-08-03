//
//  SwipeViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//


import UIKit
import ArcGIS


class SwipeViewController: UIViewController{
    
    
    var layerView: UIView!

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //道路地図レイヤー表示用のマップの作成
        let agsMapView1 = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(agsMapView1)
        
        //マップにタイルマップサービスレイヤーを追加（道路地図）
        let url1 = NSURL(string: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledMapServiceLayer1 = AGSTiledMapServiceLayer (URL: url1)
        agsMapView1.addMapLayer(tiledMapServiceLayer1, withName:"Tiled Layer1")
        
        let envelope = AGSEnvelope.envelopeWithXmin(1.5557970122810215E7, ymin:4258398.013496462, xmax:1.5558175713936899E7, ymax:4258509.895960432, spatialReference:AGSSpatialReference(WKID: 102100)) as! AGSEnvelope
        agsMapView1.zoomToEnvelope(envelope, animated: true)
   
        //衛星画像レイヤー表示用のUIViewの作成
        self.layerView = UIView(frame: self.view.bounds)
        self.view.addSubview(self.layerView)
        
        //UIViewに衛星画像レイヤー表示用のマップを追加
        let agsMapView2 = AGSMapView(frame: self.view.bounds)
        self.layerView.addSubview(agsMapView2)
        
        //マップにタイルマップサービスレイヤーを追加（衛星画像）
        let url2 = NSURL(string: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer")
        let tiledMapServiceLayer2 = AGSTiledMapServiceLayer (URL: url2)
        agsMapView2.addMapLayer(tiledMapServiceLayer2, withName:"Tiled Layer2")
        agsMapView2.zoomToEnvelope(envelope, animated: true)

        
        self.layerView.clipsToBounds = true
        
        let slider = UISlider(frame: CGRectMake(0, 100, self.view.frame.size.width, 50))
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider .addTarget(self, action: "sliderEvent:", forControlEvents: .ValueChanged)        
        self.view.addSubview(slider)
        
    }
    
    
    func sliderEvent(sender: UISlider) {
        
        //衛星画像レイヤー表示用のUIViewのframeを変更する
        self.layerView.frame = CGRectMake(0, 0, self.view.frame.size.width * CGFloat(sender.value), self.view.frame.size.height)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}