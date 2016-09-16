//
//  TimeViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS


class TimeViewController: UIViewController, AGSWebMapDelegate {
    
    
    var agsMapView: AGSMapView!
    
    var startDate: Date!
    var endDate: Date!

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        agsMapView = AGSMapView(frame: view.bounds)
        view.addSubview(agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = URL(string: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(url:url)
        agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        //時間対応レイヤー表示用のフィーチャレイヤーの追加
        let timeUrl = URL(string: "https://sampleserver3.arcgisonline.com/ArcGIS/rest/services/Hurricanes/NOAA_Tracks_1851_2007/MapServer/0")
        let agsFeatureLayer = AGSFeatureLayer(url: timeUrl, mode: .onDemand)
        agsMapView.addMapLayer(agsFeatureLayer, withName:"Time Layer")

        //マップ上でフィーチャを表示する時間範囲を指定
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        startDate = dateFormatter.date(from: "1900-1-1")
        endDate = dateFormatter.date(from: "1901-1-1")
        
        let agsTimeExtent = AGSTimeExtent(start: startDate, end: endDate)
        agsMapView.timeExtent = agsTimeExtent
        
        
        let timeItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(TimeViewController.buttonEvent))
        navigationItem.rightBarButtonItem = timeItem
        
    }
    
    
    func buttonEvent(_ sender: UIBarButtonItem) {
        
        //マップ上でフィーチャを表示する時間範囲を1年単位で変更
        var comps = DateComponents()
        comps.year = 1
        let calendar = Calendar.current
        
        let startDateNew = calendar.date(byAdding: comps, to: startDate)
        let endDateNew = calendar.date(byAdding: comps, to: endDate)

        
        startDate = startDateNew
        endDate = endDateNew
        
        print("Start:\(startDate.description)", "End:\(endDate.description)")

        let agsTimeExtent = AGSTimeExtent(start: startDate, end: endDate)
        agsMapView.timeExtent = agsTimeExtent
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
