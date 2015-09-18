//
//  WebmapViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS


class WebmapViewController: UIViewController, AGSWebMapDelegate {
    
    
    var webmap: AGSWebMap!

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Webマップを表示するマップの作成
        let agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(agsMapView)
        
        //組織のArcGIS OnlineのURLとWebマップのIDを指定して、Webマップを作成
        let portalUrl = NSURL(string: "https://ej.maps.arcgis.com/sharing")
        self.webmap = AGSWebMap(itemId: "d2dacbb4215d44da903a73c245bdce67", sharingEndPoint: portalUrl, credential: nil)
        
        self.webmap.delegate = self
        
        //Webマップを開く
        self.webmap .openIntoMapView(agsMapView)
        
    }
    

    
    func didOpenWebMap(webMap: AGSWebMap!, intoMapView mapView: AGSMapView!) {
        
        //Webマップの読み込み
        print("didOpenWebMap:\(webmap.version)")
        
    }
    
    func didLoadLayer(layer: AGSLayer!) {
        
        //Webマップに含まれるレイヤの読み込み
        print("didLoadLayer:\(layer.name)")
        
    }
    
    func didFailToLoadLayer(layerTitle: String!, url: NSURL!, baseLayer: Bool, withError error: NSError!) {
        
        //Webマップの読み込み失敗
        print("\(error)")
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}