//
//  MagnifierViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS


class MagnifierViewController: UIViewController {

    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        let agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(agsMapView)
    
        //タイルマップサービスレイヤーの追加
        let url = NSURL(string: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
            
        let point = AGSPoint(x: 15554789.5566484, y: 4254781.24130285, spatialReference:AGSSpatialReference(WKID: 102100))
        agsMapView .zoomToScale(100000, withCenterPoint: point, animated: true)
        
        //マップ上を長押しすると拡大鏡を表示
        agsMapView.showMagnifierOnTapAndHold = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
