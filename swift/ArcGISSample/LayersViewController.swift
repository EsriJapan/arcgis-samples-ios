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
        
        self.agsMapView = AGSMapView(frame: self.view.bounds)
        self.agsMapView.enableWrapAround()
        self.view.addSubview(self.agsMapView)
        
        //タイルマップサービスレイヤーの追加（衛星画像）
        let url1 = NSURL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer")
        let tiledLyr1 = AGSTiledMapServiceLayer(URL:url1)
        self.agsMapView.addMapLayer(tiledLyr1, withName:"World_Imagery")
        
        //タイルマップサービスレイヤーの追加（道路地図）
        let url2 = NSURL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr2 = AGSTiledMapServiceLayer(URL:url2)
        self.agsMapView.addMapLayer(tiledLyr2, withName:"World_Street_Map")
        
        
        let switch1 = UISwitch(frame: CGRectMake(20, 90, 20, 20))
        switch1.tag = 1
        switch1.on = true
        switch1.addTarget(self, action:#selector(LayersViewController.switchEvent), forControlEvents: .ValueChanged)
        self.view.addSubview(switch1)
        
        let switch2 = UISwitch(frame: CGRectMake(20, 130, 20, 20))
        switch2.tag = 2
        switch2.on = true
        switch2.addTarget(self, action:#selector(LayersViewController.switchEvent), forControlEvents: .ValueChanged)
        self.view.addSubview(switch2)
        
    }
    
    
    func switchEvent(sender: UISwitch) {
        
        //衛星画像・道路地図レイヤーの表示・非表示
        let sw = sender;
        
        if (sw.tag == 1) {
            
            if (sw.on) {
                self.agsMapView.mapLayerForName("World_Street_Map").visible = true
            } else {
                self.agsMapView.mapLayerForName("World_Street_Map").visible = false
            }
            
        } else if (sw.tag == 2) {
            
            if (sw.on) {
                self.agsMapView.mapLayerForName("World_Imagery").visible = true
            } else {
                self.agsMapView.mapLayerForName("World_Imagery").visible = false
            }
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}