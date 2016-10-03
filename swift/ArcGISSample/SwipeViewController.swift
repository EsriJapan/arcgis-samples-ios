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
        let agsMapView1 = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView1)
        
        //マップにタイルマップサービスレイヤーを追加（道路地図）
        let url1 = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledMapServiceLayer1 = AGSTiledMapServiceLayer (url: url1)
        agsMapView1.addMapLayer(tiledMapServiceLayer1, withName:"Tiled Layer1")
        agsMapView1.isUserInteractionEnabled = false
        
        let envelope = AGSEnvelope.envelope(withXmin: 1.5557970122810215E7, ymin:4258398.013496462, xmax:1.5558175713936899E7, ymax:4258509.895960432, spatialReference:AGSSpatialReference(wkid: 102100)) as! AGSEnvelope
        agsMapView1.zoom(to: envelope, animated: true)
   
        //衛星画像レイヤー表示用のUIViewの作成
        layerView = UIView(frame: view.bounds)
        view.addSubview(layerView)
        
        //UIViewに衛星画像レイヤー表示用のマップを追加
        let agsMapView2 = AGSMapView(frame: view.bounds)
        layerView.addSubview(agsMapView2)
        
        //マップにタイルマップサービスレイヤーを追加（衛星画像）
        let url2 = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer")
        let tiledMapServiceLayer2 = AGSTiledMapServiceLayer (url: url2)
        agsMapView2.addMapLayer(tiledMapServiceLayer2, withName:"Tiled Layer2")
        agsMapView2.zoom(to: envelope, animated: true)
        agsMapView2.isUserInteractionEnabled = false

        
        layerView.clipsToBounds = true
        
        let slider = UISlider(frame: CGRect(x: 0, y: 100, width: view.frame.size.width, height: 50))
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.addTarget(self, action: #selector(SwipeViewController.sliderEvent(sender:)), for: .valueChanged)
        view.addSubview(slider)
        
    }
    
    
    func sliderEvent(sender: UISlider) {
        
        //衛星画像レイヤー表示用のUIViewのframeを変更する
        layerView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width * CGFloat(sender.value), height: view.frame.size.height)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
