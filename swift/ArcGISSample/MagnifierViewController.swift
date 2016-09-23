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
        
        let agsMapView = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView)
    
        //タイルマップサービスレイヤーの追加
        let url = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(url:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
            
        let point = AGSPoint(x: 15554789.5566484, y: 4254781.24130285, spatialReference:AGSSpatialReference(wkid: 102100))
        agsMapView.zoom(toScale: 100000, withCenter: point, animated: true)

        //マップ上を長押しすると拡大鏡を表示
        agsMapView.showMagnifierOnTapAndHold = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
