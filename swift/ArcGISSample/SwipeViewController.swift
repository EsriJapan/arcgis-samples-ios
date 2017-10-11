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
        
        // 道路地図レイヤー表示用のマップを作成
        let mapView1 = AGSMapView(frame: view.bounds)
        view.addSubview(mapView1)
        let map1 = AGSMap(basemapType: AGSBasemapType.streets, latitude: 35.658581, longitude: 139.745433, levelOfDetail: 15)
        mapView1.map = map1
        
        // マップ操作を無効にする
        mapView1.isUserInteractionEnabled = false

        
        // 衛星画像表示用のマップを追加するUIViewを作成
        layerView = UIView(frame: view.bounds)
        view.addSubview(layerView)
        
        // 衛星画像レイヤー表示用のマップを作成
        let mapView2 = AGSMapView(frame: view.bounds)
        let map2 = AGSMap(basemapType: AGSBasemapType.imagery, latitude: 35.658581, longitude: 139.745433, levelOfDetail: 15)
        mapView2.map = map2
        mapView2.isUserInteractionEnabled = false

        // 衛星画像表示用のマップをUIViewに追加
        layerView.addSubview(mapView2)


        layerView.clipsToBounds = true
        
        // スライダーの作成
        let slider = UISlider(frame: CGRect(x: 0, y: 100, width: view.frame.size.width, height: 50))
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.addTarget(self, action: #selector(SwipeViewController.sliderEvent(sender:)), for: .valueChanged)
        view.addSubview(slider)
        
    }
    
    
    @objc func sliderEvent(sender: UISlider) {
        
        // 衛星画像レイヤー表示用のUIViewのframeを変更する
        layerView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width * CGFloat(sender.value), height: view.frame.size.height)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
