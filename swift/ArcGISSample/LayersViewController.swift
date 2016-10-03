//
//  LayersViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//


import UIKit
import ArcGIS


class LayersViewController: UIViewController {
    
    var agsMapView: AGSMapView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        agsMapView = AGSMapView(frame: view.bounds)
        agsMapView.enableWrapAround()
        view.addSubview(agsMapView)
        
        //タイルマップサービスレイヤーの追加（衛星画像）
        let url1 = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer")
        let tiledLyr1 = AGSTiledMapServiceLayer(url:url1)
        agsMapView.addMapLayer(tiledLyr1, withName:"World_Imagery")
        
        //タイルマップサービスレイヤーの追加（道路地図）
        let url2 = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr2 = AGSTiledMapServiceLayer(url:url2)
        agsMapView.addMapLayer(tiledLyr2, withName:"World_Street_Map")
        
        
        let switch1 = UISwitch(frame: CGRect(x: 20, y: 90, width: 20, height: 20))
        switch1.tag = 1
        switch1.isOn = true
        switch1.addTarget(self, action:#selector(LayersViewController.switchEvent(sender:)), for: .valueChanged)
        view.addSubview(switch1)
        
        let switch2 = UISwitch(frame: CGRect(x: 20, y: 130, width: 20, height: 20))
        switch2.tag = 2
        switch2.isOn = true
        switch2.addTarget(self, action:#selector(LayersViewController.switchEvent(sender:)), for: .valueChanged)
        view.addSubview(switch2)
        
    }
    
    
    func switchEvent(sender: UISwitch) {
        
        //衛星画像・道路地図レイヤーの表示・非表示
        let sw = sender
        
        if (sw.tag == 1) {
            
            if (sw.isOn) {
                agsMapView.mapLayer(forName: "World_Street_Map").isVisible = true
            } else {
                agsMapView.mapLayer(forName: "World_Street_Map").isVisible = false
            }
            
        } else if (sw.tag == 2) {
            
            if (sw.isOn) {
                agsMapView.mapLayer(forName: "World_Imagery").isVisible = true
            } else {
                agsMapView.mapLayer(forName: "World_Imagery").isVisible = false
            }
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
